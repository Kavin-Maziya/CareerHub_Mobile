# CareerHub Mobile

CareerHub is a job listing and application platform.
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
