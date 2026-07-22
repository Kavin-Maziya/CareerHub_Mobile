# CareerHub Mobile

CareerHub is a job listing and application platform.
---



## Assignment 2.4 — Authentication and Secure API Flow
 
**Written decisions dated:** 2026-07-23
 
---
 
## Part 1 — Written Decisions
 
### Question 1 — Token storage and platform security boundaries
 
**Why access/refresh tokens cannot live in SharedPreferences**
 
On Android, `SharedPreferences` writes a plain XML file to
`/data/data/<package_name>/shared_prefs/<file_name>.xml` inside the app's
private data directory. Under normal circumstances this file is protected
only by Linux discretionary access control — the directory is created with
mode `700` and the file with mode `660`, owned by the app's unique UID, so
another *installed app* cannot open it through the normal filesystem APIs.
That protection is about process isolation, not encryption: the token sits
on disk as readable UTF-8 text with no cryptographic protection at all.
 
The concrete attack does not require root. Two ordinary channels expose the
file even on a stock, non-rooted device:
 
1. **`adb backup` / USB debugging.** If the device has USB debugging enabled
   (common on developer or test devices, and trivial to enable if the phone
   is briefly unattended) and the app has not explicitly set
   `android:allowBackup="false"`, `adb backup` can pull the entire app data
   directory — including `shared_prefs/*.xml` — to a connected computer with
   no root and no exploit, just a USB cable and an unlocked screen.
2. **Android Auto Backup to Google Drive.** By default, Android backs up app
   data (again including `shared_prefs`) to the user's Google Drive. Anyone
   who gains access to that Google account — via a phishing page, a reused
   password, or a session token from an unrelated breach — can restore the
   backup onto an attacker-controlled device and read the tokens directly
   out of the XML file, without ever touching the victim's phone.
Either path hands an attacker the raw access and refresh tokens, which is
equivalent to full account takeover until the tokens are revoked
server-side. Neither path requires cracking anything, because
`SharedPreferences` never encrypted the data in the first place.
 
**What the iOS Keychain provides that a file on disk does not**
 
`flutter_secure_storage` stores tokens in the iOS Keychain rather than in a
plist or a file. The Keychain gives two protections a raw file never has:
 
- **Passcode-tied encryption.** Keychain items are encrypted with keys
  derived from the device passcode (combined with a device-specific UID
  key). A file written to the app sandbox has no such gate — anything that
  can read the sandbox can read the file's bytes.
- **Hardware-backed key storage (Secure Enclave).** On devices with a Secure
  Enclave, the cryptographic keys protecting Keychain items can be generated
  and used *inside* that isolated co-processor. The key material never
  enters the main OS's address space, so even a full jailbreak of the
  primary kernel does not expose the raw key.
`kSecAttrAccessibleWhenUnlocked` only permits access while the device is
actively unlocked at the moment of the read — the strictest option, but it
blocks background code (e.g. a background token refresh) whenever the phone
is locked. `kSecAttrAccessibleAfterFirstUnlock` permits access any time
after the user has unlocked the device once since the last reboot, even if
they subsequently lock it again — this is what lets a background process
refresh a token while the phone sits locked in a pocket.
 
If tokens must survive an app **reinstall**, `kSecAttrAccessibleAfterFirstUnlock`
is the right choice. Keychain items are not tied to the app's binary or its
sandbox the way `SharedPreferences`/`UserDefaults` are — deleting and
reinstalling the app does not clear them (they are only cleared on request
or when the device is wiped). Choosing `AfterFirstUnlock` means the
just-reinstalled app can read the previously stored token immediately on
first launch without requiring the device to be unlocked at that *exact*
instant, which matters if the reinstall is triggered by an MDM push or a
background App Store update rather than a manual, unlocked launch.
 
**Why `minSdkVersion` must be 23**
 
`flutter_secure_storage` uses `EncryptedSharedPreferences` on Android, which
wraps the ordinary `SharedPreferences` file with AES-256 encryption for both
keys and values (via the Jetpack Security / Tink implementation), instead of
writing plaintext XML. The master key that performs that encryption is
generated and held by the **Android Keystore system**, whose modern
key-generation API (`KeyGenParameterSpec` /
`KeyGenParameterSpec.Builder`) was introduced in **API level 23 (Android
6.0, Marshmallow)**.
 
Below API 23 the `KeyGenParameterSpec` class simply does not exist on the
device, so the very first attempt to create or access a key throws at
runtime — not at compile time — with `java.lang.NoClassDefFoundError`
(reported by the runtime as *"Could not find class
'android.security.keystore.KeyGenParameterSpec$Builder'"*). The app builds
and installs cleanly on an API 21/22 device; it only crashes the first time
`flutter_secure_storage` tries to touch the Keystore. This is exactly why
`android/app/build.gradle`'s `minSdkVersion` was raised to 23 in Part 2 —
the Gradle build system has no way to catch this at compile time, since the
missing class only fails to resolve at the device's actual runtime.
 
---
 
### Question 2 — The sealed `AuthState` and the two-layer state machine
 
**Why an enum is insufficient**
 
A Dart `enum` can only represent a fixed set of *labels* — it cannot attach
a differently-typed payload to each case. `Authenticated` needs to carry a
`User` object and `AuthError` needs to carry a `String` message; an enum
value like `AuthStatus.authenticated` has nowhere to hold that data, so the
codebase would have to bolt on nullable side-fields (`User? currentUser`,
`String? errorMessage`) next to the enum and hope every reader remembers
which fields are valid for which case. Nothing enforces that discipline —
it is entirely possible to end up with `AuthStatus.unauthenticated` paired
with a stale `errorMessage` still set from three logins ago.
 
A `sealed class` fixes this because each subtype **is** its payload.
`Authenticated` *has* a `User user` field that only exists when you are
looking at an `Authenticated` instance; `AuthError` *has* a `String message`
field that only exists on `AuthError`. Combined with Dart 3 pattern
matching (`switch (state) { Authenticated(:final user) => ..., AuthError(:final message) => ... }`),
the compiler enforces exhaustiveness — if a fifth subtype were ever added,
every `switch` handling `AuthState` would fail to compile until it was
updated — and it is structurally impossible to read `user` off an
`AuthError` or vice-versa, which an enum-plus-nullable-fields design cannot
guarantee.
 
**The two distinct loading states**
 
1. **`AsyncValue` loading, at cold boot.** This is triggered the moment
   `AuthNotifier.build()` starts running — before it has read anything from
   secure storage. `authProvider`'s value is `AsyncLoading<AuthState>`.
   During this window the router's `redirect` callback checks
   `auth.isLoading` and returns `null` — it deliberately does *not*
   redirect. The user sees whatever the router's `initialLocation` renders
   mid-load (in this app, a brief flash of the jobs route's own loading
   state) rather than being bounced to `/login` and immediately bounced
   back if the token turns out to be valid.
2. **`Authenticating`, during a live login call.** This is triggered
   explicitly inside `AuthNotifier.login()`, which sets
   `state = AsyncData(Authenticating())` synchronously before it ever awaits
   the network call. Here `authProvider`'s value is `AsyncData<AuthState>`
   wrapping `Authenticating()` — the outer `AsyncValue` is *not* loading,
   the *inner* sealed state is. The router's redirect callback sees
   `auth.isLoading == false` (it's `AsyncData`) and `isAuthenticated == false`
   (the value isn't `Authenticated`), so it would redirect to `/login` if
   the user weren't already there — which they are, since login only
   happens from the login screen. What the user actually sees is the
   `LoginScreen`'s own `FilledButton` swap to a small
   `CircularProgressIndicator` and become disabled, with no navigation.
**`ref.read` vs `ref.watch` inside `redirect`**
 
`appRouter`'s function body uses `ref.watch(authStateListenableProvider)`
once, at construction time, purely to obtain the `ChangeNotifier` that is
handed to GoRouter as `refreshListenable`. If the `redirect` *callback
itself* used `ref.watch(authProvider)` instead of `ref.read`, every emission
of `authProvider` would trigger two independent effects at once: GoRouter
re-running `redirect` because `refreshListenable` fired, **and** Riverpod
scheduling a rebuild of the `appRouter` provider itself because one of its
watched dependencies changed. Rebuilding `appRouter` tears down and
reconstructs the entire `GoRouter` instance — including its internal
navigator state — which the user would experience as the whole app
appearing to "reset": in-flight page transitions cancel, and on some Flutter
versions the current route flashes or pops unexpectedly during what should
have been a silent redirect check.
 
These two usages don't contradict each other because they operate at
different scopes: `ref.watch` in the *provider body* is what makes
`appRouter` itself reactive to auth changes — exactly once, when the
`GoRouter` is (re)built — while `ref.read` inside the *redirect closure*
means the closure reads the current value without subscribing to it again.
The reactivity is already fully handled by `refreshListenable`, which calls
`redirect` for you on every auth change; asking Riverpod to *also* watch
inside `redirect` would just double the same signal through two different
mechanisms.
 
---
 
### Question 3 — The two-Dio architecture and the concurrent 401 queue
 
**The infinite loop `AuthRepository` avoids**
 
If `AuthRepository.login()`/`tryRefresh()` used the shared `dioProvider`
Dio (the one with `AuthInterceptor` attached) instead of their own plain
Dio, then `tryRefresh()`'s `POST /api/auth/refresh` would flow through
`AuthInterceptor.onRequest` (attaching whatever access token is currently
stored) and, on a 401, through `AuthInterceptor.onError`. Trace it:
`tryRefresh()` calls the refresh endpoint → the refresh token is expired →
server returns 401 → `AuthInterceptor.onError` fires → sees a 401 → checks
whether refresh is already in progress → since this *is* a refresh attempt,
`onError` would treat it as an ordinary failed request and attempt to
refresh the token to retry it → which means calling the refresh endpoint
*again* → which returns 401 again → which triggers `onError` again. Nothing
in that cycle terminates on its own; each "fix the 401" attempt just
produces another 401 that the same interceptor tries to fix by refreshing
again. This is precisely why `AuthRepository` is given its own bare Dio
with **no interceptors attached** — its calls can 401 and simply propagate
that failure back to the caller as a `Failure`/`null`, instead of being
caught by the very interceptor that exists to handle *other* repositories'
401s.
 
**Three simultaneous 401s and refresh token rotation**
 
If three parallel API calls all 401 at the same instant (access token just
expired) and there were no queue, all three would independently read the
same stored refresh token and POST it to `/api/auth/refresh` at roughly the
same time. With **refresh token rotation**, the server treats a refresh
token as single-use: the first request to arrive rotates it into a new
access/refresh pair and invalidates the old refresh token. The second and
third requests arrive carrying that now-already-used refresh token, which
the server correctly (and, from the client's confused perspective,
unpredictably) rejects as invalid or reused — potentially even flagging it
as a stolen-token indicator and revoking the whole session, logging the
user out for no reason they caused.
 
The `Completer<String>` queue prevents this by ensuring only **one** of the
three ever calls the refresh endpoint. The first 401 to hit `onError` finds
`_isRefreshing == false`, sets it to `true`, and becomes the request that
actually performs the refresh. The second and third 401s arrive while
`_isRefreshing` is already `true`, so instead of refreshing they each create
a `Completer<String>`, push it onto `_queue`, and `await completer.future` —
parking themselves rather than issuing any HTTP call. When the first
request's refresh succeeds, it iterates `_queue`, calling
`completer.complete(newAccessToken)` on each parked completer; that resumes
their `await`, they attach the new token to their original failed request,
and retry it via `retryDio.fetch(...)` — no second or third refresh call
ever reaches the server.
 
**The refresh-endpoint 401 guard**
 
The guard in `onError` — checking whether the *failing* request's own path
contains `/api/auth/refresh` — exists to catch the case where the refresh
call itself is the one that came back 401 (the refresh token is expired or
already rotated away). Without that guard, a failed refresh would fall
through into the same "start a refresh" branch as any other 401: it would
find `_isRefreshing` still `true` (since we're inside the refresh flow) or,
after the `finally` resets it, would treat its own failure as "just another
401 to fix" and attempt to refresh again — recreating the exact infinite
loop described above, except now entirely inside the interceptor rather
than in `AuthRepository`. Concretely, without the guard, a failed refresh
would leave `_isRefreshing` stuck in an inconsistent state relative to
`_queue` (queued completers never drained, or drained with success instead
of the real failure) and `onUnauthenticated()` would never be invoked — so
`authProvider` is never invalidated, `AuthNotifier` never re-runs `build()`,
and the router's redirect never fires. The user would keep looking at a
spinner or a silently-failing screen indefinitely, never reaching
`/login`, even though their session had already, definitively, ended
server-side.
 
---
 
### Question 4 — Logout ordering and the circular import problem
 
**Why invalidate data providers before calling `logout()`**
 
If `logout()` ran first, `authProvider`'s state would flip to
`Unauthenticated` immediately, `AuthStateListenable` would call
`notifyListeners()`, and GoRouter's `redirect` would send the user to
`/login` on the very next frame. Riverpod then tears down the widget
subtree that was watching `jobsNotifierProvider` (and any other
authenticated-only provider). If a background fetch inside
`JobsNotifier.build()`/`getJobs()` was still in flight at that moment, the
provider is disposed mid-request: the in-flight `Future` may still complete
afterwards and attempt to set `state` on a provider that Riverpod has
already disposed, which either throws, is silently swallowed, or — worse —
completes successfully and writes stale, now-logged-out-user data into the
Isar cache just as the *next* user's session begins. Explicit invalidation
before the redirect is safer because `ref.invalidate(jobsNotifierProvider)`
deterministically cancels/discards that in-flight state on our own
schedule, rather than leaving the outcome to whatever order Flutter happens
to tear down widgets versus resolve pending Futures.
 
**The circular import that a naive implementation would create**
 
If invalidation logic lived inside `AuthNotifier.logout()`, `auth_notifier.dart`
would need to import `jobs_notifier.dart` to call
`ref.invalidate(jobsNotifierProvider)`. Trace the chain: `auth_notifier.dart`
imports `jobs_notifier.dart` → `jobs_notifier.dart` imports
`jobs_repository.dart` (to read `jobsRepositoryProvider` inside its
`build()`) → `jobs_repository.dart` imports `auth_interceptor.dart` and
`auth_provider.dart` (to attach `AuthInterceptor` to `dioProvider`) →
`auth_provider.dart` imports `auth_notifier.dart` (to expose
`authProvider` for the redirect bridge) — which is the file we started
from. Dart's compiler detects this at analysis time; because Dart allows
mutually-recursive imports (unlike some languages that hard-error), the
practical failure shows up instead as `build_runner`/the analyzer being
unable to resolve one or both `part` files consistently, and/or the
generated `.g.dart` files referencing types that create unresolvable
forward references — in practice this surfaces as analyzer errors like
*"Type 'X' not found"* or generator failures during `build_runner build`,
and is exactly why the assignment routes this responsibility through
`auth_provider.dart`'s `onUnauthenticatedProvider` indirection instead,
and why the actual invalidation call lives in the UI's logout handler
rather than inside `AuthNotifier` itself.
 
**Why `logout()` sets `AsyncData(Unauthenticated())`, not an error**
 
Logging out is an intentional, successful state transition, not a failure —
setting `AsyncError` would make `authProvider` render as an error state
everywhere it's consumed (e.g. `auth.hasError` checks), which is
semantically wrong and could trigger error-handling UI (retry buttons, error
banners) for something that isn't an error at all. `Unauthenticated` wrapped
in `AsyncData` correctly says "we successfully resolved to: logged out."
 
Downstream: during the redirect, `filteredJobsProvider` (built on top of the
now-invalidated `jobsNotifierProvider`) is torn down before the jobs screen
itself unmounts, so it never has a chance to expose stale data to whatever
transient frame renders during navigation to `/login`. The Isar cache,
however, is **not** touched by `logout()` — only secure storage is cleared —
so the raw `JobCache` rows from the previous session remain on disk. On the
very next cold boot, if that same install is opened again,
`AuthNotifier.build()` finds no token in secure storage and correctly
returns `Unauthenticated`, so the router sends the user to `/login`
regardless of what's cached. But if the *app itself* is reinstalled onto a
**new device** where secure storage starts empty and the Isar database also
starts empty, there's no leftover data to worry about. The scenario worth
flagging is a single device where the *app's storage* was cleared
selectively (e.g. only secure storage lost to an OS quirk while app data
persists) — in that case `getCachedJobs()` would still be able to surface
another user's previously cached job listings for a fraction of a second
before the fresh `getJobs()` call overwrites the cache, which is why Isar
cache invalidation on logout is called out as a Stretch-adjacent hardening
step worth considering if CareerHub ever supports multiple accounts on one
device.
 
---


# Assignment 2.3
## Part 1 - Written Decisions

### Question 1 — The two persistence mechanisms and why they are not interchangeable

**Why the jobs list can't live in SharedPreferences:** 
- SharedPreferences only stores String, bool, int, double, and List<String> and List<Job> isn't any of those, so every write would require manually calling jsonEncode(jobs.map((j) => j.toJson()).toList()) first, and every read would require jsonDecode(...) followed by re-mapping each raw map back into a Job via Job.fromDto(JobDto.fromJson(...)). That decode step runs synchronously on the main isolate which drives the UI's frame rendering. 
- If the user navigates to the jobs screen at the exact moment a large cached list is being JSON-decoded, that decode blocks the main isolate until it finishes, which means Flutter can't process touch input, can't render a new frame, and can't respond to the navigation itself — the app visibly freezes for the duration of the decode, precisely because "small key-value pairs" was never designed to carry a structured, potentially-large list.

**Why the jobs list can't be an arbitrary List<Job> in Isar without a schema class:**
- The @collection annotation and Isar's code generator are producing the actual binary storage layout and native query bindings for a class — a fixed byte offset for each field, an auto-incrementing Id primary key, and generated IsarCollection<T> accessor methods (.where(), .filter(), .put(), etc.) that map directly onto Isar's native storage engine. 
- A plain Dart class has none of this — Isar has no way to know how to serialize an arbitrary object's fields into its binary format, what the primary key is, or how to build a queryable index, without the generator reading an @collection-annotated class declaration first.

**Why this requires a third class, not annotating Job or JobDto:**
- Job is @freezed, and Freezed's const factory constructor pattern means every field is a final, immutable property implemented by a generated, hidden class (_Job) — but Isar's generator requires every persisted field to be declared late (mutable, settable after construction), since Isar's native binary deserialization populates a schema object's fields after construction, not through a constructor call.
- @freezed and @collection are structurally incompatible on the same class: one demands immutable, constructor-populated fields, and the other demands mutable post-construction-populated fields. JobDto has the same problem, plus it's already carrying the API's exact camelCase JSON shape — mixing that with Isar's own storage concerns would blur "this class mirrors the network response" with "this class is a database row," the same kind of concern-mixing the DTO/domain split already exists to prevent.


### Question 2 — Isar's type limitations and your conversion strategy

**The enum:** Job.employmentType is an EmploymentType enum (fullTime, partTime, contract, internship). Since Isar 3.x has no native enum support, the schema class (JobCache) will store it as a plain String — employmentType.name and reconstruct it on read via EmploymentType.values.firstWhere((e) => e.name == cache.employmentType, orElse: () => EmploymentType.fullTime). fullTime is the fallback when a stored string doesn't match any current enum case. A fallback is required, rather than letting the lookup throw, because the cache is written by a previous version of the app — if a future release ever renames or removes an EmploymentType value, old cached rows would contain a string that no longer matches anything, and without a fallback, reading the cache would throw a StateError and crash the exact code path (getCachedJobs()) that's supposed to be the reliable, guaranteed-to-work fallback when the network has already failed. A crash in the safety net defeats its entire purpose.

**The DateTime field:** Job.closingDate is a nullable DateTime. Isar 3.x supports DateTime natively, storing it in its own binary format rather than requiring conversion to an int of epoch milliseconds. This is meaningfully safer than manually storing closingDate.millisecondsSinceEpoch because of time zone handling: DateTime.now() and API-parsed DateTime values in Dart carry an explicit UTC-or-local flag, and Isar's native DateTime storage preserves that distinction through serialization and back. If a developer instead stored a raw epoch integer, and even one code path reconstructed it via DateTime.fromMillisecondsSinceEpoch(epoch) (which defaults to local time) while the original value had been UTC (or vice versa), the reconstructed DateTime would be silently shifted by the device's UTC offset — a job with a closing date of 2026-07-24 23:00 UTC could be read back and displayed as 2026-07-25 on a device several hours ahead of UTC, with no exception thrown anywhere to reveal the bug. Isar's native DateTime support avoids this entire class of error by never round-tripping through a bare integer in the first place.

### Question 3 — Initialization order and the provider override pattern

**What WidgetsFlutterBinding.ensureInitialized() does, and why it must come first:**
- It creates and installs the WidgetsBinding singleton, which in turn establishes Flutter's platform channel mechanism — the message-passing bridge that lets Dart code call into native platform code (and vice versa).
- path_provider's getApplicationDocumentsDirectory() and SharedPreferences.getInstance() both work by sending a method-channel message to native Android/iOS/Windows code and awaiting a native response; that channel simply doesn't exist until the binding is created. If getApplicationDocumentsDirectory() (or any platform-channel call) is invoked before ensureInitialized(), the exact error thrown is:

*Binding has not yet been initialized.:* a FlutterError (or, depending on the specific call path, an AssertionError/StateError wrapping that same message) raised by Flutter's own binding-assertion checks, precisely because the channel the call needs doesn't exist yet.

**Why the placeholder providers throw instead of returning null/a default:**
- A throw produces an immediate, loud, descriptive failure at the exact call site where the mistake occurred — the error message names the provider and says exactly what needs overriding.
- Returning null or a silent placeholder default would let the mistake propagate — a null Isar instance might not fail until three calls deeper, inside getCachedJobs(), producing a confusing NoSuchMethodError far from the actual root cause (forgetting the override in main()). This mirrors Dart's own late keyword philosophy: "I am promising this will have a real value before anyone reads it" — and a broken promise should fail immediately and explain itself, not degrade gracefully into a harder-to-diagnose bug later.

**Override timing in the ProviderScope lifecycle:** overrideWithValue installs its value into the provider container synchronously, as part of constructing the ProviderScope widget itself — before that widget (or anything beneath it) ever builds a single frame.
- Since runApp(ProviderScope(overrides: [...], child: ...)) only executes after main() has already awaited Isar.open() and SharedPreferences.getInstance() to completion, by the time any widget's build() method runs and calls ref.watch(isarProvider), the override is already fully in place. So yes — if a provider's build() synchronously calls ref.watch(isarProvider), the override is visible at that exact moment, because the entire override list is applied before the widget tree is constructed at all, not lazily as each provider happens to be read.

**Two disadvantages of a lazy FutureProvider<Isar> (calling Isar.open() on first read) instead:**
1. Compile-time-invisible ordering bug: any widget that happens to be the first to read the provider triggers the actual disk-opening Future at an unpredictable moment during the widget tree's build — if two different providers both lazily depend on Isar and are read in a different order across builds, you could get a Future that's still pending exactly when a synchronous-looking code path (like FilterNotifier.build(), which is written to work purely synchronously against prefsProvider) assumes it already has a resolved value; this ordering problem is invisible to flutter analyze, since the types all check out — it's a purely runtime timing failure.
2. Every consumer becomes async-shaped for no reason: since a FutureProvider<Isar> exposes AsyncValue<Isar> rather than a plain Isar, every single provider or widget that needs Isar (the jobs repository, the applications repository, anything future) would need to unwrap an AsyncValue and handle a loading/error state that, in reality, only ever occurs once, for a fraction of a second, at app startup — needless complexity spreads to every consumer instead of being resolved once in main().

### Question 4 — The cache-then-network contract with Riverpod's state machine

**The three state transitions during build():**

- **Before build() starts → immediately after build() is first called:** AsyncValue is AsyncLoading(). This is Riverpod's default state the instant a provider starts computing and hasn't produced any value yet — caused simply by build() having started executing (specifically, by the fact that no state = ... assignment has happened yet). The widget's .when() renders the CircularProgressIndicator; the ListView is not visible.

- **After getCachedJobs() returns a non-empty list → the state = AsyncData(cachedJobs) line executes:** AsyncValue transitions from AsyncLoading() to AsyncData(cachedJobs). This line is the direct cause. The widget rebuilds immediately — the spinner disappears and the ListView renders the cached jobs, even though build() itself is still running (it hasn't returned yet).

- **After getJobs() (the network call) resolves and build() finally returns:** AsyncValue transitions from AsyncData(cachedJobs) to AsyncData(freshJobs) (on Success) or, on Failure with a non-empty cache, effectively stays at AsyncData(cachedJobs) (since the function returns the same cached list again) — or, only if the cache was empty, transitions to AsyncError(exception). The return statement at the end of build() is what causes this. In the success/cache-preserved cases, the widget simply re-renders the (possibly updated) ListView — no spinner reappears, since Riverpod doesn't revert to AsyncLoading mid-flight once real data has been assigned.

**What would happen if the Failure arm threw instead of returning the cache:** 
- filteredJobsProvider derives its value by calling ref.watch(jobsProvider) (the raw notifier) and applying .whenData(...) to transform it. If jobsNotifier's build() threw an Exception instead of returning the cached list, the underlying jobsProvider's AsyncValue would become AsyncError(exception, stackTrace) — and since .whenData() only transforms the data case, passing loading/error through unchanged, filteredJobsProvider would also expose AsyncError.
- The jobs screen's .when() call would then render its error branch — the icon, message, and retry button — even though perfectly good, previously-cached data exists and could have been shown. Throwing would only be the more correct choice if the cache is genuinely empty — i.e., there's truly nothing useful to show the user, and an honest error state (rather than a blank screen) is the right response.

**isOfflineProvider's state on a cold boot when already offline:** connectivity_plus's stream does not emit on subscription — it only emits when connectivity changes.
- This means at the moment the jobs screen first renders after a cold boot with the device already offline, connectivityStreamProvider's AsyncValue is still AsyncLoading() (no event has arrived yet), and per the isOfflineProvider implementation (loading and error arms both return false), isOfflineProvider reports false — the offline banner does not appear on that very first frame, even though the device genuinely has no connectivity.
- *This is an acceptable trade-off, not a bug to fix, because:*
1. the banner is a secondary, informational affordance, not something gating functionality — the cached jobs list still renders correctly regardless of what the banner shows; 
2. the window of incorrectness is extremely short-lived — the platform typically emits the current connectivity state within the same frame or the next, at which point the banner catches up;
3. building a more "correct" initial-state check (e.g., an eager one-shot connectivity poll before the stream subscribes) would add real complexity and a second connectivity-checking code path purely to eliminate a sub-second, cosmetic delay in a non-blocking UI element.

---
# Assignment 2.2  Immutable Models, Dart 3 & Freezed

## Question 1 — The equality problem in your running app
- Dart's default == on a plain class compares two instances by memory address and two separately constructed Job objects with identical field values are never == to each other unless they're literally the same object in memory. When the API returns the same jobs twice (initial load, then a pull-to-refresh), the notifier constructs a brand new List<Job> from the second response, even if every field of every job is identical to the initial list before, this is a new list containing new Job instances. Under identity equality, Riverpod has no way to know the content is unchanged; it's forced to conclude the data is different, because the only thing it can compare is memory identity, and two different List<Job> instances (even wrapping equal data) are never == by default. This means every pull-to-refresh — successful or not, changed or not — is treated as a fresh and new state.

- Concrete consequence in the widget layer: HomeScreen's build() calls ref.watch(sortedJobsProvider). Because the emitted AsyncValue<List<Job>> is never equal to the previous one even when the underlying jobs are unchanged, HomeScreen rebuilds in full on every refresh, and ListView.builder/GridView.builder reconstructs every single JobCard from scratch via _buildCard. If I tried to optimize this later with ref.watch(sortedJobsProvider.select((async) => async)) to skip rebuilds when nothing actually changed, select relies on == to decide whether to notify listeners and since it can never see two states as equal, select provides zero benefit, and every JobCard and any local state inside it, like a hypothetical "expanded description" toggle gets torn down and rebuilt unnecessarily on every refresh, even when the visible data is identical.

- Freezed generates a real value-based ==/hashCode that compares every field.

| Field | Type | Has correct built-in value equality?| 
|----|----------|-------------------------------|
| id | String | ✅Yes — String.== compares content |
| title | String | ✅Yes |
|companyString | ✅Yes |
| location | String | ✅Yes | 
| description | String | ✅Yes |
| employmentTypeString | ✅Yes |
| isOpen | bool | ✅Yes |
| salaryDisplay | String? | ✅Yes |
|closingDate | DateTime? | ✅Yes — DateTime already overrides == to compare the represented instant, not object identity |

- No field requires extra work. Every field on Job is either a primitive or DateTime which already has correct value equality built into Dart's core library, so Freezed's generated == will be fully correct the moment it's applied since there's no nested custom object, List, or Map field on Job that would need special handling

## Question 2 — Which models get json_serializable and which do not

- JobDto is responsible for reading raw JSON from the API response; Job is the domain model the UI consumes.
- **Why json_serializable on Job would break at the boundary:** json_serializable's default behavior matches a JSON key to a Dart field only when their names are identical. The API's JSON keys are companyName and isActive, but Job's fields are named company and isOpen — deliberately renamed during the DTO-to-model mapping in Assignment 2.1 for UI readability. If json_serializable were attached directly to Job, it would look for JSON keys literally named company and isOpen in the response and find nothing (since the API sends companyName/isActive), leaving those fields null or throwing a parse error — unless every mismatch were manually annotated with @JsonKey(name: '...'), which would just be re-implementing Job.fromDto's translation job in a second place, defeating the purpose of having a DTO at all.

- **What the generator reads to know how to parse each field:** The generator reads the field names and declared types inside the const factory constructor of JobDto. Because JobDto was implemented to mirror the API's JSON keys one-to-one (companyName, isActive, postedAt, salaryDisplay, closingDate, applicationCount, employmentType — all matching ASP.NET Core's default camelCase JSON serialization exactly), no @JsonKey(name: ...) annotations are needed anywhere in JobDto since every field name already matches its corresponding JSON key, so json_serializable's default name-matching handles every field automatically.
- Job.fromDto's continued role: It remains the single place where API-shaped names (companyName, isActive) get translated into UI-shaped names (company, isOpen), and where fields the API sends but the UI doesn't currently use (postedAt, applicationCount) are simply not carried forward. If the API renames a field tomorrow, two files change: job_dto.dart and job.dart's fromDto method we should update the one mapping line that references the old DTO field name. If fromDto didn't exist and Job parsed JSON directly, the same rename would force Job itself to either take on the API's exact naming or scatter @JsonKey annotations directly onto the domain model — coupling the class every widget in the app depends on (JobCard, JobDetailScreen, every provider) directly to the API's JSON shape, exactly the risk the DTO layer exists to prevent.

## Question 3 — Freezed and custom behaviour: the private constructor

- **What const Job._() does:** Freezed's code generation produces a hidden implementation class (_Job) that holds the actual field storage and mixes in _$Job (the generated ==, hashCode, copyWith, toString). The abstract Job class I write becomes a shell whose only real constructor is Job._() — a private, empty, generative constructor that _Job calls into via super._(). Declaring Job._() is what gives you a place to add your own members — getters like canApply and displaySalary — directly on the Job class body, because those need an actual constructor to exist on the class for Dart to allow additional non-factory members at all. Without declaring it, trying to add an instance method or getter to a @freezed class produces a build_runner generation error, since Freezed has no accessible constructor path to attach your custom code to the class hierarchy it's generating.

- **What must change about fromDto:** Freezed treats every factory constructor on an annotated class as a potential union-type variant — not just ones using the = _ClassName redirect syntax, but any factory declaration at all, since Freezed's generator scans all constructors named factory to build its metadata. factory Job.fromDto(JobDto dto) { ... } currently exists as exactly that: a factory constructor with a body. Left as-is after adding @freezed, this collides with Freezed's union-variant detection and produces generator errors or unintended sealed-class behavior. The fix: convert it from a factory constructor into a plain static Job fromDto(JobDto dto) { ... } method — identical body, no longer a constructor at all. The call site remains syntactically identical (Job.fromDto(dto) in jobs_repository.dart doesn't change) because Dart's dot-syntax for calling a named constructor (ClassName.name(args)) and calling a static method (ClassName.name(args)) are indistinguishable at the call site — only the declaration changes, not how callers invoke it.

- **A related wrinkle worth flagging now:** Job.closed and Job.remote are currently plain named generative constructors (not factories) that directly set fields via initializer lists (e.g. : isOpen = false). Under Freezed's abstract-class-plus-hidden-implementation pattern, Job's fields become abstract getters implemented only by the generated _Job class — there's no way for a second generative constructor on the abstract Job class to assign to those fields directly, since they aren't real settable fields on Job itself anymore. This means Job.closed and Job.remote cannot survive the Freezed conversion in their current form — they'll need to become static helper methods too (mirroring the fromDto fix), each simply calling the primary Job(...) factory with the appropriate defaults filled in. I'll flag this explicitly again when we get to Part 5's implementation, but wanted it on record now since it's a direct consequence of this question's reasoning, not a separate surprise.

## Question 4 — Sealed classes and the compile-time guarantee

- **What sealed enforces:** All direct subclasses of a sealed class must be declared within the same file (technically, the same library) as the sealed class itself. This file-location rule is what makes exhaustiveness checking possible: since Dart's compiler can see every subclass of ApiResult<T> at the point the sealed class is declared — no other file, anywhere in the project or in a consuming package, can add a third subclass — the compiler has a complete, closed picture of every possible shape ApiResult<T> can take.

- **What exhaustiveness checking means, and what happens if you omit a case:** When you write a switch expression over a value of a sealed type, the compiler cross-checks your case/pattern arms against that complete, closed set of subclasses. If you handle only Success and omit Failure, the compiler produces a compile-time error (non_exhaustive_switch_expression) — the code simply does not compile until every subclass is handled (or you add an explicit wildcard _ arm, which you'd have to do deliberately, not by accident). Contrast with abstract class: if ApiResult<T> were merely abstract, any file anywhere in the codebase (or in a package that imports it) could define a third subclass the compiler has no visibility into at the switch's declaration site — so the compiler could never guarantee you've covered every case, and a missing arm would either require a mandatory default/wildcard branch or silently fail at runtime rather than being caught while writing the code.

- **Why Failure<T> carries T even though it never stores a value of that type:** ApiResult<T> is generic, and for Failure<T> extends ApiResult<T> to type-check as a proper subtype, Failure must itself be parameterized by the same T — otherwise it would be a raw, non-generic type that couldn't be treated polymorphically alongside Success<T> wherever ApiResult<T> is expected. Concretely, a method declared to return Future<ApiResult<List<Job>>> needs to be able to return either Success<List<Job>> or Failure<List<Job>> interchangeably — if Failure weren't parameterized by T, returning it from that method would be a type mismatch, even though the failure case has no actual List<Job> data to carry.


---

# Assignment 2.1 — HTTP, Repositories & Code Generation
 
 
## Question 1 — Why a DTO, not a fromJson on the Job model
 
**Field-name mismatches, with the Flutter file that would break if the API renamed that field:**
 
| API field (`JobListResponse`) | Flutter `Job` field | Mismatch |
|---|---|---|
| `Id` (Guid) | `id` (int) | Name matches, but **type differs** — Guid vs int |
| `CompanyName` | `company` | **Different Name** |
| `SalaryDisplay` (String, pre-formatted) | `salary` (`double?`) | **Different Name and Type** — the API already formats salary as a display string; the Flutter model stores a raw nullable number and formats it itself via `displaySalary` |
| `IsActive` | `isOpen` | **Different Name** |
| `EmploymentType` (string enum: `FullTime`, `PartTime`, `Contract`, `Internship`) | `employmentType` (String) | Casing matches via JSON conversion, but the **enum values** don't match the hyphenated strings currently hardcoded in the Flutter app (`'Full-Time'`, `'Part-Time'`) |
 
- Every one of these mismatches would break `lib/models/job.dart` directly
if `fromJson` lived there and the API renamed a field.
 
**How many files change if the API renames a field, with a DTO in place?** 
- One — `lib/data/job_dto.dart`. The `fromJson` parsing logic that
reads the raw JSON key lives entirely inside `JobDto`; nothing else in
the app touches the API's actual field names.
 
**How many files change without a DTO — `fromJson` directly on `Job`?**
- The risk isn't just file count, it's architectural: `Job` becomes simultaneously responsible for being the UI's domain model (with getters like `displaySalary` and `canApply` that `JobCard`, `HomeScreen`, and `JobDetailScreen` all depend on) *and* for matching the API's exact JSON shape. Any API change even a harmless internal rename — directly threatens every widget in the app that already depends on `Job`. With
the DTO in between, `Job` never changes when the API's JSON shape changes; only `JobDto.fromJson` and the small `Job.fromDto` mapping function need updating. The numbers differ because the DTO absorbs all of the API's volatility into one small, disposable file, while `Job` and everything depending on it stays stable.
 
**Should the DTO capture fields the `Job` model doesn't use, like `PostedAt` and `ApplicationCount`?** Yes. Six months from now, CareerHub will likely want to sort by "most recently posted" or show application count on the dashboard — if `JobDto` only
captured the fields `Job` currently uses, adding either feature would require re-editing the DTO and re-testing the parsing logic at that point, rather than the data simply already being there and ready to be used. Capturing the full API response costs nothing now and avoids a second migration effort later.
 
## Question 2 — Why the repository owns Dio, not the provider
 
**Every class currently calling `ref.watch(jobsProvider)` or `ref.watch(filteredJobsProvider)`:**
- `HomeScreen` (via `filteredJobsProvider` )
- `JobDetailScreen` (via the raw `jobsProvider`, deliberately bypassing the filtered one)
**How many of those need to know jobs came from HTTP vs. a hardcoded list?** Zero. Both only ever cared that they receive an `AsyncValue<List<Job>>` — neither has ever needed to know how that list was produced, even back when it was a `Future.delayed` fake.
 
**Switching HTTP clients, with the repository pattern — which files change?** Just `lib/data/jobs_repository.dart` — `JobsNotifier`, `HomeScreen`, `JobDetailScreen`, and every filter/sort provider remain untouched, since they only ever depended on `JobsRepository.getJobs()` returning a `List<Job>`, never on Dio itself.
 
**Without the repository — Dio used directly inside `JobsNotifier.build()` — which files change?** `lib/providers/jobs_notifier.dart` itself, and potentially the test's fake notifier in `test/widget_test.dart`, since a test override extending `_$JobsNotifier` would need updating if the real class's internals changed shape too.
 
**Which list is shorter, and why does it matter on a team?** The repository-pattern list is shorter. On a team where multiple people work on different files simultaneously, a change confined to `jobs_repository.dart` can be made, reviewed, and
merged by whoever owns "how do we talk to the API," without touching `jobs_notifier.dart` or a test file a teammate might be mid-edit on reducing merge conflicts and letting HTTP logic and state-management logic evolve independently.
 
## Question 3 — What @riverpod generates and why the red underline is expected
 
**What is `_$JobsNotifier`, where does it come from, and when does the red underline disappear?** `_$JobsNotifier` is a base class that does not exist yet at the moment you write `class JobsNotifier extends _$JobsNotifier` it's generated by `riverpod_generator` reading the annotated class and producing the actual Riverpod plumbing into a `.g.dart` file alongside it. The red underline disappears when we run the command below:
```
dart run build_runner build --delete-conflicting-outputs
```
 
**Which part of `JobsNotifier` does the generator read to determine the type parameters, and where do you find the result?** The generator reads the **return type of `build()`** — `Future<List<Job>>` — to determine that the generated provider should be typed as `AsyncNotifierProvider<JobsNotifier, List<Job>>`. Opening
`lib/providers/jobs_notifier.g.dart` after running the generator shows the `jobsNotifierProvider` declaration using exactly that signature, derived directly from `build()`'s declared return type.
 
**A mistake possible before code generation existed, and why the generator prevents it:** A developer manually writing `AsyncNotifierProvider<JobsNotifier, List<Job>>(...)` could typo or drift the second type parameter — e.g. leaving it as `List<JobDto>` after refactoring `build()` to return `Future<List<Job>>`, forgetting to update the provider declaration to match. This compiles successfully, since both `Job` and `JobDto` are valid types, but produces a **runtime type error** the first time a widget reads through the provider expecting `List<Job>` and gets `List<JobDto>` instead. The generator makes this impossible because there's no second, independently-typed declaration to drift out of sync — the type parameters are derived mechanically from `build()`'s actual return type every time the code is regenerated.
 
## Question 4 — Why the test overrides the provider instead of mocking the network
 
- **Trace the exact failure path with no API server available:** Dio attempts to open a connection to the configured base URL and receives a connection refusal or timeout, throwing a `DioException`. Inside `JobsNotifier.build()`, since this is an async function whose `Future` fails, `AsyncNotifier` catches the thrown exception and converts the provider's state into `AsyncValue.error(exception, stackTrace)` — this doesn't crash the app, it represents the failure as data. The widget tree renders whatever `AsyncValue.when()`'s `error` branch specifies (icon + message + retry button). 
- **Does the test fail on an assertion, or throw an unhandled exception?** Neither,  initially the app handles the failure gracefully via `AsyncValue.error`. The *test* fails on an **assertion** — specifically ones expecting job card text to be present (`find.text(...)` returns `findsNothing` instead of `findsOneWidget`), because the UI is
legitimately showing the error state, not the data state the test expects.
 
- **What does `overrideWith` do — what does it replace, what does it leave untouched?** `overrideWith` replaces the *implementation* the provider resolves to — swapping the real `JobsNotifier` (which calls the actual repository/Dio) for a fake, test-only notifier — while leaving every widget that watches `jobsNotifierProvider` completely untouched, since those widgets only ever interact with the provider's public interface
(`AsyncValue<List<Job>>`), never the notifier's internals.
 
- **The single responsibility of the widget test:** To verify that `HomeScreen` renders the correct UI for a given, known set of job data — not whether that data can actually be fetched from a real server.
- **Two things the widget test is explicitly not responsible for, and what kind of test covers each instead:**
1. Whether `JobsRepository.getJobs()` correctly parses a real API response into `Job` objects — that's a **unit test** on `JobsRepository` (or `JobDto.fromJson`), likely using a mocked Dio client or a canned JSON fixture.
2. Whether the live API server is reachable and behaves correctly end-to-end — that's **manual/integration testing** against a running instance of the API, not something `flutter test` should depend on.
 

---
# Assignment 1.4 — Deep Navigation & Route Architecture
 
## Question 1 — Route tree
 
| Path | Screen | Shell status |
|---|---|---|
| `/jobs` | `HomeScreen` (job list, filter chips, sort toggle) | Inside shell — `NavigationBar` visible |
| `/jobs/:id` | `JobDetailScreen` | Nested under the Jobs branch (for back-stack purposes), but rendered on the **root navigator** via `parentNavigatorKey` — full screen, `NavigationBar` hidden |
| `/saved` | `SavedScreen` | Inside shell — `NavigationBar` visible |
 
```
StatefulShellRoute.indexedStack
├── Branch 0 (Jobs tab)
│   └── /jobs ──────────────► HomeScreen        [shell: visible]
│         └── /jobs/:id ────► JobDetailScreen    [shell: hidden — full screen]
└── Branch 1 (Saved tab)
    └── /saved ─────────────► SavedScreen         [shell: visible]
```
 
**The job detail screen is outside the shell** as a full screen, no `NavigationBar`. The shell is the persistent frame (the two-tab bar) that stays fixed while its content swaps between branches;
routes inside it render within that frame, while routes outside it take over the full screen via `parentNavigatorKey`, hiding the tab bar entirely. A job detail view is dense — title, company, location,
employment type, salary, closing date, full description — and benefits from every pixel of vertical space, so keeping a persistent tab bar visible while the user reads a wall of text works against the content
rather than for it. **Real app reference:** LinkedIn uses the same behaviour — tapping a job from the feed or search results opens a full-screen detail view with no bottom tab bar; only a back arrow returns you to the list.
 
**What URL is active when the user first opens the app?** `/jobs` — the initial home screen location.
 
**What URL is active when reading the detail for the third job in the list?** `/jobs/{job.id}` — `/jobs/3` if that job's stable `id` field happens to be `3`
 
**What does the system back button do from the detail screen?** It pops back to `/jobs`, returning to the job list with its previous scroll position, filter selection, and sort order intact — since
`StatefulShellRoute.indexedStack` preserves the Jobs branch's navigation stack independently of the Saved branch.
 
**What if the user opened `/jobs/3` directly via a notification tap, then pressed back?** They land on `/jobs` (the job list), not the previous app or home screen. My route tree supports this because
`/jobs/:id` is declared as a *child* of `/jobs` — GoRouter synthesizes the full parent stack for a nested path even on a direct deep-link entry, so `/jobs` exists underneath `/jobs/3` on the back stack
automatically, with no extra logic needed.
 
## Question 2 — context.go vs context.push
 
| Action | Method | Justification |
|---|---|---|
| (a) Tap a job card → detail slides in | `context.push` | The user expects the back button to return them to exactly where they were in the list — `push` adds to the stack rather than replacing it. |
| (b) Tap "Saved" tab | `goBranch` (the shell's tab-switching equivalent of `go`) | Switching tabs is a lateral move, not a drill-down — the user doesn't expect pressing back afterward to cycle back through every previous tab they'd visited, so it shouldn't grow the back stack. |
| (c) "Log Out" | `context.go('/login')` | `go` replaces the current stack entirely — this is a security requirement, since a logged-out user must never be able to press back and land on an authenticated screen. |
| (d) "Browse Similar Roles" → jobs list with a filter | See below | — |
 
**The wrong choice for (d): `context.push`.** If "Browse Similar Roles" pushes a new instance of the jobs list every time it's tapped, a user browsing several job details in sequence and tapping "Browse Similar"
from each one accumulates multiple redundant jobs-list screens on the stack. Pressing back once wouldn't return them to the job they were just viewing — it would show yet another jobs-list screen, and they'd need to
press back several more times to actually exit, directly violating the expectation that one back press undoes one navigation action.
 
## Question 3 — Why IDs in URLs, not objects or indices
 
**Scenario 1 — filter chips:** Say index `0` is captured in a URL while the "Remote" filter is active — at that moment, index `0` is the remote content-writer job. If the user later clears the filter back to "All"
without navigating away, index `0` in the unfiltered list is now the Senior Frontend Software Engineer job instead — a completely different listing now answers to the same captured index.
 
**Scenario 2 — sort order (Stretch A):** With the A–Z/Z–A sort toggle, index `0` under "A–Z" sorting is whichever job's title comes alphabetically first, but index `0` under "Z–A" is the job whose title
comes last. The same index number silently refers to two different jobs purely based on which sort button was tapped last — no filter change even required.
 
**The push notification paragraph:** For a position-based URL to reliably reopen the correct job, the app's filter selection, sort order, and the underlying job list's exact contents and ordering would all need
to be identical at the moment the notification is tapped as they were when the notification was generated — and that state would need to survive being backgrounded, force-quit, or relaunched fresh in between.
None of that can be guaranteed: the user might switch filters between receiving and tapping the notification, the app may have been killed and relaunched with everything reset to its defaults ("All" / "A–Z"), or the
backend's job list may have changed (a listing closed, a new one was added, shifting every subsequent position by one). A stable `id` field sidesteps all of this entirely, since it identifies the job itself
rather than its transient position in some particular view of the data.
 
## Question 4 — What the test is about to break and why
 
**What changes when `MaterialApp` becomes `MaterialApp.router`:** Instead of `MaterialApp` taking a fixed `home:` widget as the root of the tree, `MaterialApp.router` delegates the entire widget tree's
construction to a router configuration (`routerConfig: goRouter`). The tree the test inspects is no longer "whatever widget I passed in" — it's dynamically resolved by GoRouter's `RouterDelegate` based on the current
location, meaning `HomeScreen` now sits several layers deeper in the tree (inside a `Router`, a `Navigator`, the `StatefulShellRoute`'s `IndexedStack`) rather than being the direct child of `MaterialApp`.
 
**Does the test need changes to see the jobs list, given `initialLocation` is `/jobs`?** No structural changes are needed to *reach* the jobs list — GoRouter resolves `initialLocation` synchronously
on the very first frame, so `pumpWidget` still lands directly on `HomeScreen`'s content without any extra navigation step in the test.
The Assignment 1.3 fixes (`ProviderScope` wrap, advancing the fake clock past the async delay) still apply unchanged.
What **does** need to change: the test must now also assert that the `NavigationBar`
destination labels ("Jobs", "Saved") are present in the tree, since those are new text nodes that didn't exist before — and because `StatefulShellRoute.indexedStack` keeps all branches' widgets mounted
simultaneously (that's the point of `IndexedStack` preserving state), any text that happens to appear in both the Jobs screen and the Saved screen would need its `findsNWidgets` count adjusted accordingly, even though only one branch is visually showing at a time.
 
---
# Assignment 1.3 — Live State & Reactive Filters
 
## Part 1: Written decisions
### Question 1 — ref.watch versus ref.read
 
The `ref.watch` inside `build()` subscribes the widget to a provider's node in the reactive dependency graph: whenever that provider's value changes, Riverpod
automatically schedules a rebuild for every widget watching it. That's exactly what `build()` needs, since a widget's job is to stay in sync with the graph. Using `ref.watch` inside a callback like `onSelected` is inappropriate because callbacks aren't part of the build lifecycle. A subscription created there has no `build()` to reattach to on the next frame. `ref.read` reaches into the graph once, grabs the current value, and creates no subscription — perfect for "the user just
tapped this chip, read the notifier and tell it to update," but insufficient inside `build()` because a widget that only ever reads once renders correctly on its first build and then never updates again. If these were reversed, the user would see two different bugs: with `ref.read` in `build()`, the job list would render once and then freeze — tapping filter chips would silently update the provider but the visible list would never change, since the widget stopped listening after its first render. With `ref.watch` in a callback, it's more subtly
wrong — it blurs the distinction between "this widget needs to react to
state" and "this event handler needs to act on state once," inviting
bugs as the provider graph grows.
 
### Question 2 — Choosing the right provider for each piece of state
 
| Data | Provider type | Justification |
|---|---|---|
| Full job list (async, simulated network delay) | `AsyncNotifierProvider<JobsNotifier, List<Job>>` | The data requires actual async fetch logic (a `build()` method with a simulated delay) rather than a one-shot read; `AsyncNotifier` gives `AsyncValue`'s loading/data/error states for free. |
| Selected filter chip label | `StateProvider<String>` | It's a single, simple, directly-settable piece of UI state (which chip is selected) with no async component. |
| Filtered list (derived from the two above) | `Provider<AsyncValue<List<Job>>>` | It's pure computed state that should never be set directly, only recalculated automatically whenever either dependency changes; a plain `Provider` enforces that by exposing no way to write to it. |
 
**The manual-sync bug:** Storing the filtered list in its own
`StateProvider<List<Job>>` and updating it manually introduces a
**stale-state (synchronization) bug** — the derived value can silently
drift out of sync with its sources because nothing forces it to
recompute automatically. A concrete CareerHub scenario: the user taps
"Remote," the filtered `StateProvider` is set correctly, but then the
underlying job list reloads (e.g. after a retry from an error state)
with a different set of jobs — if the filtered `StateProvider` isn't
manually re-triggered at that exact moment, the user keeps seeing the
*old* filtered snapshot, filtered against data that no longer exists.
 
### Question 3 — AsyncValue and your UI contract
 
- **loading** → centered `CircularProgressIndicator`, so the user gets clear feedback that something is happening rather than assuming the app is frozen.
- **error** → an icon, a short message, and a retry button, so the user understands something went wrong and has an immediate way to try again without restarting the app.
- **data** → pass the list to the existing `LayoutBuilder` from Assignment 1.2, since the UI's only job is to display what successfully loaded.
**The fourth condition:** within the `data` case, you must additionally check whether the **filtered list is empty**. If forgotten, a user selecting a filter with no matching jobs sees a completely blank body — reading as a bug or a frozen app rather than "there's nothing here." The fix: check `if (filteredJobs.isEmpty)` inside the data branch and render
an explicit "No jobs match this filter" message instead of handing an empty list straight to the grid/list builder.
 
### Question 4 — What your test is about to break and why
 
**Failure mode 1 — architecture change to `ConsumerWidget`:**
`HomeScreen` now needs a `WidgetRef`, which only exists inside a
`ProviderScope`. The current test pumps the app with no `ProviderScope`
wrapping it, so it throws immediately before rendering anything. **Fix:**
wrap the pumped widget in `ProviderScope(child: CareerHubApp())` in the
test.
 
**Failure mode 2 — async loading:** `pumpWidget` only pumps a single
frame, and since the job list now loads via `AsyncNotifier` with a
simulated delay, the frame right after `pumpWidget` is still in the
**loading** state — the job cards don't exist yet. Asserting on job
title text immediately will fail, not because the app is broken, but
because the test is checking before the data arrives. **Fix:** call
`await tester.pump(const Duration(seconds: 2))` to advance the fake
clock past the simulated delay, followed by `await tester.pumpAndSettle()`,
before asserting on job card content.
 

---
# Assignment 1.2 — The Responsive List & Adaptive Theme
 
## Question 1 — The constraint your current layout depends on
 
- The `Scaffold.body` passes a **bounded** height constraint down, but `Column`
does not forward that bound to its children and each child gets a loose and **unbounded** height (`0 to infinity`) unless wrapped in `Expanded` or `Flexible`. The chip row is fine with that, since it has intrinsic size, but `ListView.builder` has no intrinsic size and always tries to expand in order to fill the space it's offered given "up to infinity," and Flutter throws `RenderBox was not laid out: vertical viewport was given unbounded height`. 

- **The fix:** We should wrap `ListView.builder` in **`Expanded`**, which reintroduces a bound by giving it exactly the space left over after the `Column`'s other children are laid out.
 
## Question 2 — The grid cell problem
 
### 2a. Content inventory
 
| Field | Required / Conditional |
|---|---|
| Title | Required |
| Company | Required |
| Location + employment type row | Required |
| `displaySalary` | Required (always renders — either a value or "Market-related") |
| Status chip | Required |
| Closing date row | **Conditional** — only when `closingDate != null` |
 
**Minimum height** (no closing date row): ~120px — title, company, location/type row, salary row, plus card padding/margins.
 
**Maximum height** (closing date present): ~146px — adds the closing date row plus its spacing.
 
### 2b. childAspectRatio derivation
 
- At a 390px phone width in a 2-column grid, with `crossAxisSpacing: 8` and `padding: EdgeInsets.all(8)` on both sides:
 
```
cell width = (390 - (2 × 8 padding) - 8 spacing) / 2 = 366 / 2 = 183px
```
 
- Using the **maximum** height estimate (146px) rather than the minimum — deliberately, see 
 
**Chosen value: `1.2`** (rounded slightly down from 1.25 for a small
safety margin).
 
### 2c. What happens with a mismatched estimate
 
- If the aspect ratio had been derived from the **minimum** height (120px), a fully populated card forced into that shorter cell would produce a classic Flutter render overflow "bottom overflowed by N pixels" warning, with the closing date row (and possibly part of the salary row) cut from the main content. This is not acceptable because it's visually broken and looks like a bug to any user.
 
- By basing the ratio on the **maximum** height instead, the trade-off flips: a minimal card (no closing date) now has a little unused whitespace at the bottom of its cell. This **is** acceptable because empty space reads as normal spacing, while overflow reads as broken software.
 
## Question 3 — Dark mode breakage audit
 
| Colour reference | Classification | Role |
|---|---|---|
| Title text style | Theme-referenced | `textTheme.titleMedium` |
| Company text colour | Theme-referenced | `colorScheme.onSurfaceVariant` |
| Location/type icons + text | Theme-referenced | `colorScheme.onSurfaceVariant`, `textTheme.bodySmall` |
| Salary text colour | Theme-referenced | `colorScheme.primary` |
| Closing date row | Theme-referenced | `colorScheme.onSurfaceVariant`, `textTheme.bodySmall` |
| Open chip background | Theme-referenced | `colorScheme.primaryContainer` |
| Open chip text | Theme-referenced | `colorScheme.onPrimaryContainer` |
| Closed chip background | Theme-referenced | `colorScheme.errorContainer` |
| Closed chip text | Theme-referenced | `colorScheme.onErrorContainer` |
 
- **No hardcoded colours.** In Assignment 1.1, every colour decision was routed through `Theme.of(context).colorScheme` or `Theme.of(context).textTheme` from the start and the open/closed distinction specifically used `primaryContainer`/`errorContainer` rather than a literal `Colors.green`/`Colors.red`, because those roles carry semantic meaning in the M3 system (a "positive/confirming state" vs. an "error/negative state") rather than being chosen for their literal shade.

- This means there were no changes done on Part 3b (removing hardcoded colours) the existing widget is already dark-mode-safe by construction.
 
## Question 4 — The extraction decision
 
**Component to extract: `JobStatusBadge`** (currently the inline
`_StatusChip` private class inside `job_card.dart`).
 
Applying the three criteria:
 
1. **Single, nameable responsibility** — "Displays job open/closed
   status." Five words, one job.
2. **Rendered in more than one place** — Beyond `JobCard`, this is
   very likely to reappear on an employer's listing-management
   dashboard, an application-tracking view, and possibly a compact
   list-row variant later in the course — anywhere a job's open/closed
   state needs a quick visual signal.
3. **Testable in isolation** — It depends only on a single
   `bool isOpen` parameter, not on `Job` or any parent widget state, so
   it can be widget-tested completely independently of `JobCard`.

**All three criteria are met**
 
**Cost of not extracting:** If left inline, testing the status-colour logic would require standing up the entire `JobCard` (and by extension a full `Job` instance) just to verify a boolean-to-colour mapping which is an unnecessary test setup for what should be an isolated check. It would also invite duplication: the next time a status indicator is needed elsewhere in the CareerHub App, a developer would either copy-paste the private `_StatusChip` logic (risking the two implementations silently drifting apart over time) or rebuild it from scratch.
 
---
 
## Part 2 verification (ListView.builder migration)
 
- ✅ Jobs list is `List<Job>`, defined as `static final` at the class
  level — not recreated on every rebuild
- ✅ `ListView.builder` used with `itemCount`/`itemBuilder`, driven by the
  jobs list rather than hardcoded widgets
- ✅ Pinned horizontal filter chip row ("All", "Remote", "Full-Time")
  added above the list, visual only — no filtering logic yet
- ✅ `ListView.builder` wrapped in `Expanded` per the Question 1 fix — no
  crash, no unbounded height error
- ✅ All four job variants (fully populated, no salary, closed, remote)
  present and rendering correctly
## Part 3 verification (Adaptive theming)
 
- ✅ `darkTheme` added using the same seed colour with
  `brightness: Brightness.dark`
- ✅ `themeMode: ThemeMode.system` set — app follows the OS-level setting
- ✅ Zero hardcoded colours found or needed changing, per the Question 3
  audit — all colours were already `colorScheme`/`textTheme` references
  from Assignment 1.1
- ✅ Dark mode and light mode both confirmed manually in the browser, with
  Open and Closed badges clearly readable in both
**Dark mode:**
 
![CareerHub dark mode — Open and Closed badges visible](assets\images\dark-mode-screenshot.png)
 
**Light mode:**
 
![CareerHub light mode — Open and Closed badges visible](assets\images\light-mode-screenshot.png)
 
Both screenshots show the same job set, including the "Data Analyst
Intern" (Closed) card and multiple "Open" cards, confirming the
`primaryContainer`/`errorContainer` badge colours and `colorScheme`-based
text/background colours all adapt correctly between modes with no
jarring hardcoded values.
 
## Part 4 verification (LayoutBuilder responsive layout)
 
- ✅ `LayoutBuilder` switches to a two-column `GridView.builder` at
  width ≥ 600px, and stays on the single-column `ListView.builder` below
  that
- ✅ Both layouts share the same `_buildCard(context, index)` method — no
  duplicated `itemBuilder` logic
- ✅ `childAspectRatio: 1.2` applied, matching the Question 2 derivation
- ✅ `crossAxisSpacing: 8`, `mainAxisSpacing: 8`, and `padding: 8` applied
  to the grid delegate
- ✅ Filter chip row remains pinned above both layouts
- ✅ All four job variants, including the closed and remote jobs, render
  correctly in the grid with no overflow
**Wide layout (grid):**
 
![CareerHub two-column grid at width >= 600px](assets\images\grid-layout-screenshot.png)
 
**Narrow layout (list):**
 
![CareerHub single-column list at width < 600px](assets\images\list-layout-screenshot.png)
 
 
## Part 5 verification (Widget extraction)
 
- ✅ `JobStatusBadge` extracted to `lib/widgets/job_status_badge.dart`
- ✅ `StatelessWidget`, const-constructible
- ✅ Accepts only `bool isOpen` — not the full `Job` object
- ✅ Every colour is a `colorScheme` reference
  (`primaryContainer`/`errorContainer`,
  `onPrimaryContainer`/`onErrorContainer`)
- ✅ `JobCard` updated to use `JobStatusBadge` in place of the previous
  inline `_StatusChip` — no duplicated code
- ✅ No business logic in the extracted widget — purely presentational
- ✅ Confirmed via the Flutter Outline panel that `JobStatusBadge` appears
  as a named node in `JobCard`'s widget tree, not folded into an
  anonymous subtree
**Criteria met (from Question 4):** all three — single, nameable
responsibility; likely reuse across future employer/dashboard views; and
isolated testability independent of `Job` or `JobCard` state.

---

# Assignment 1.1 — Written Requirements

## Question 1 — Nullability decisions

| Field | Decision | Domain justification |
|---|---|---|
| `title` | Non-nullable | A listing without a title isn't a job posting it renders as an incomplete data item that shouldn't exist as a `Job` object at all. |
| `company` | Non-nullable | Every listing is created by a company as part of that company's onboarding and a job without a company is a ghost Job. |
| `location` | Non-nullable | Jobseekers filter and browse by location as a primary decision factor, even remote roles have a defined location value ("Remote"), so the field should always present. |
| `salary` | Nullable | An employer may choose not to disclose salary because some Job posts allow salaries to be negotiated with the candidate and some even show "Market Realated" which I will implement in this Assignment. |
| `closingDate` | Nullable | Some employers list roles as open-ended with no fixed application deadline. |
| `description` | Non-nullable | A listing without any description gives a jobseeker nothing to evaluate; CareerHub requires at least a minimal description to post a Job. |
| `employmentType` | Non-nullable | Employment type (full-time, part-time, contract) is a core filter jobseekers rely on, and every listing is categorized at creation. |
| `isOpen` | Non-nullable | A job's open/closed state is a must to always be available because closed Jobs sometimes have to be filtered out for the candidate. |

**Most dangerous nullable field:** `salary` is the most dangerous field to
render without an explicit null check. If forgotten, a jobseeker would see
a literal `"null"` string where a salary figure should be displayed ("Salary:
null")  which reads as a rendering bug, undermines trust in the platform,
and could even be misread as the job paying nothing, discouraging a
qualified applicant from applying for the Job.

## Question 2 — The salary type decision

**Chosen type: `double?`**

- The CareerHub API will return salary as a numeric type because
backend systems that model money as raw numeric values keep sorting,
filtering, and range-based queries (e.g. "jobs paying over R30,000")
trivial at the database level and formatting as a display string is a
presentation concern that belongs in the frontend, not the data layer.
- Storing salary as a pre-formatted string in the backend would make numeric
operations like sorting-by-salary or salary-range filters require string
parsing on every request, which is fragile compared to querying a numeric
column directly.

- On screen, the user never sees the raw `double` instead they see the output of
`displaySalary`, which formats the raw number into a currency string (e.g.
"R35 000 per month"). When salary is confidential, the model stores
`salary = null`, and `displaySalary` returns `"Market-related"` rather
than the widget needing to check for null itself, keeping that business
logic in exactly one place.

## Question 3 — Status representation

**Chosen approach: `bool isOpen`**

**Limitation:** A `bool` can only represent two states, but a real
CareerHub listing has four possible states (Active, Closed, Draft,
Expired). Using `isOpen` forces every non-active state — Draft and
Expired — to collapse into `false`, indistinguishable from a job the
employer deliberately closed. The UI currently can't tell a jobseeker
*why* a job isn't open, and an employer can't distinguish an unpublished
draft from an expired listing.

- **Week 2 fix:** Dart's **enum** would model this more safely because it
can represent all four mutually exclusive states explicitly
(`enum JobStatus { active, closed, draft, expired }`), making it a
compile-time error to handle only two of the four states.

## Question 4 — Named constructor justification

1. **`Job.closed(...)`** — CareerHub employers regularly close listings
   once a position is filled, and marking a job closed should be an
   explicit, readable action in code (`Job.closed(...)`) rather than
   remembering to manually pass `isOpen: false` alongside every other
   field.
2. **`Job.remote(...)`** — Remote roles are common enough on CareerHub
   that pre-filling `location: 'Remote'` via a named constructor prevents
   inconsistent location strings ("remote", "Remote", "Work from home")
   that would otherwise fragment location-based filtering across
   listings created by different employers.

---

## Scratch output (Part 2 verification)

Output from `scratch/job_demo.dart`, run via `dart run scratch/job_demo.dart`:

```
Job(title: Senior Frontend Software Engineer, company: TechCorp Cape Town, location: Cape Town, isOpen: true, salary: 37500.0, closingDate: 2026-07-24 00:00:00.000)
  canApply: true
  displaySalary: R37500 per month
---
Job(title: UX/Web Designer, company: DesignHouse Sandton, location: Sandton, isOpen: true, salary: confidential, closingDate: none)
  canApply: true
  displaySalary: Market-related
---
Job(title: Data Analyst Intern, company: DataWorks Pretoria, location: Pretoria/Hybrid, isOpen: false, salary: 18500.0, closingDate: 2026-06-19 00:00:00.000)
  canApply: false
  displaySalary: R18500 per month
---
Job(title: Part-Time Content Writer/Promoter, company: MediaCo, location: Remote, isOpen: true, salary: 15000.0, closingDate: 2026-07-24 00:00:00.000)
  canApply: true
  displaySalary: R15000 per month
---
```

This confirms `canApply` is `false` only for the closed job, `displaySalary`
falls back to `"Market-related"` for the job with no salary, and
`toString()` produces readable, identifiable output for all four states.

---

## Colour choice

- I chose a deep teal seed colour (`#0D3B36`) because it conveys
professionalism and trust qualities central to a platform where users
make career and hiring decisions while remaining visually distinct from
the blue used by most competing job platforms.

---

## Part 3 verification (JobCard)

Manually confirmed on both Web and Android emulator:

- ✅ Job with no salary shows **"Market-related"** — not "null", not a blank line
- ✅ Job with no closing date shows **no closing date row at all** — not "null", not "Closes: "
- ✅ Closed job's card visually communicates status via a red "Closed" chip
- ✅ Remote job's location renders correctly as **"Remote"**
- ✅ Toggling a job from open to closed in the hardcoded list and hot
  reloading updates the card's chip without restarting the app

---

## Part 4 verification (App shell)

- ✅ Four job variants present, covering fully populated / no-salary /
  closed / remote edge cases
- ✅ App title is **"CareerHub"**, not "Flutter Demo"
- ✅ Material 3 seed colour set via `ColorScheme.fromSeed()` (deep teal,
  justified above)
- ✅ Hot reload confirmed updating a card when a job's status changes

---

## Getting Started (Clone & Run)

**This setup works for low-end PCs — Chrome/Web is the recommended target
for quick iteration, with Android emulator instructions included for those
who want to test on a virtual device.**

### Step 1: Install prerequisites

1. Install **Git**
2. Install **VS Code**
3. Open VS Code → Extensions → search and install **Flutter** (Dart comes
   bundled with it)
4. Install **Android Studio** once, just for the Android SDK — if you're on
   a low-spec machine, you don't need to open it again; VS Code handles
   everything else
5. Accept Android licenses:
   ```
   flutter doctor --android-licenses
   ```
   Press `y` to accept all.

### Step 2: Clone this repository

```
git clone <repository-url>
cd careerhub
```

### Step 3: Get dependencies

```
flutter pub get
```

### Step 4: Verify your setup

```
flutter doctor
```

Ignore any Android Studio/emulator-specific warnings if you only plan to
run on Web.

### Step 5: Choose a device and run

**Option A — Web (recommended for low-end machines):**

1. `Ctrl+Shift+P` → **Flutter: Select Device** → choose **Chrome** or **Edge**
2. Open `lib/main.dart`
3. Press **F5**, or click the debug button top-right

**Option B — Android emulator (for those who want a mobile-accurate test):**

1. Open **Android Studio → Device Manager** and create/start a virtual
   device (Pixel 7/8 recommended; API 34–35 for stability)
2. Once the emulator is running, `Ctrl+Shift+P` → **Flutter: Select Device**
   → choose the running emulator
3. Open `lib/main.dart`, press **F5**

Either way, the app launches showing the CareerHub job listings.

### Step 6: Hot reload

While the app is running, edit anything in `lib/main.dart` or the widgets
(e.g. toggle a job's `isOpen` value), save (`Ctrl+S`) — the running app
updates instantly without a full restart.

---

## Already installed but outdated version?

Check your current version:
```
flutter --version
```

Update:
```
flutter upgrade
```

Re-run `flutter doctor` afterward to confirm.

---

## Before committing to version control

1. Clean build artifacts and dependencies:
   ```
   flutter clean
   ```
2. Confirm `.gitignore` includes:
   ```
   .dart_tool/
   .flutter-plugin-dependencies
   build/
   .packages
   ```
3. Commit:
   ```
   git add .
   git commit -m "your message"
   ```
4. Restore dependencies after cloning/cleaning:
   ```
   flutter pub get
   ```

---

## Troubleshooting

| Error | Solution |
|---|---|
| `flutter` not recognized | Restart terminal/VS Code (PATH changes need a fresh shell) |
| Android Studio warning | Ignore if only using Web |
| License error | Run `flutter doctor --android-licenses` again |
| Stuck on upgrade | Run `flutter upgrade --force` |
| Web app not showing as device | Confirm Chrome/Edge is installed, restart VS Code |
| Emulator "System UI isn't responding" | Usually low host RAM — close other heavy apps (Android Studio, Docker) while the emulator runs |
| Emulator stuck/failing to boot | Try Cold Boot instead of Quick Boot in AVD settings; consider a lower API level (34/35) over the newest preview image |

---

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
