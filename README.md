# CareerHub Mobile

CareerHub is a job listing and application platform.

---

# Assignment 1.2 — The Responsive List & Adaptive Theme
 
## Question 1 — The constraint your current layout depends on
 
- The `Scaffold.body` gives its child a **bounded** height constraint which is the
screen height minus the app bar and system insets. A `Column`, however,
does not pass that bound down to its non-flexible children along the main
axis — instead, each child is given a **loose but unbounded maximum
height** (`0 to infinity`) unless it's wrapped in `Expanded` or
`Flexible`. This is fine for widgets with intrinsic size (like the
horizontal chip row), but `ListView.builder` is a scrolling viewport with
no intrinsic size — it always tries to expand to fill all available space
along its scroll axis. When `Column` offers it "up to infinity,"
`ListView` takes it, and Flutter throws `RenderBox was not laid out:
vertical viewport was given unbounded height`.
 
**The fix:** wrap `ListView.builder` in **`Expanded`**. `Expanded` tells
the `Column` to first lay out its other children (the chip row) normally,
then give the `ListView.builder` exactly the *remaining* bounded space.
This is constraints-flow-down in action: `Scaffold` bounds `Column`,
`Column` can't pass that bound through automatically, and `Expanded` is
the mechanism that reintroduces the bound for the one child that needs it.
 
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
 
**Minimum height** (no closing date row): ~120px — title, company,
location/type row, salary row, plus card padding/margins.
 
**Maximum height** (closing date present): ~146px — adds the closing date
row plus its spacing.
 
### 2b. childAspectRatio derivation
 
At a 390px phone width in a 2-column grid, with `crossAxisSpacing: 8` and
`padding: EdgeInsets.all(8)` on both sides:
 
```
cell width = (390 - (2 × 8 padding) - 8 spacing) / 2 = 366 / 2 = 183px
```
 
Using the **maximum** height estimate (146px) rather than the minimum —
deliberately, see 2c — gives:
 
```
childAspectRatio = width / height = 183 / 146 ≈ 1.25
```
 
**Chosen value: `1.2`** (rounded slightly down from 1.25 for a small
safety margin).
 
### 2c. What happens with a mismatched estimate
 
If the aspect ratio had instead been derived from the **minimum** height
(120px), a fully populated card forced into that shorter cell would
produce a classic Flutter render overflow — the yellow-and-black striped
"bottom overflowed by N pixels" warning, with the closing date row (and
possibly part of the salary row) clipped or invisible. This is not
acceptable — it's visually broken and looks like a bug to any user.
 
By basing the ratio on the **maximum** height instead, the trade-off
flips: a minimal card (no closing date) now has a little unused
whitespace at the bottom of its cell. This **is** acceptable — empty
space reads as normal spacing, while overflow reads as broken software.
Whitespace is the safe failure mode; clipping is not.
 
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
 
**Zero hardcoded colours found.** In Assignment 1.1, every colour
decision was routed through `Theme.of(context).colorScheme` or
`Theme.of(context).textTheme` from the start — the open/closed
distinction specifically used `primaryContainer`/`errorContainer` rather
than a literal `Colors.green`/`Colors.red`, because those roles carry
semantic meaning in the M3 system (a "positive/confirming state" vs. an
"error/negative state") rather than being chosen for their literal shade.
This means Part 3b (removing hardcoded colours) requires no changes — the
existing widget is already dark-mode-safe by construction.
 
## Question 4 — The extraction decision
 
**Component to extract: `JobStatusBadge`** (currently the inline
`_StatusChip` private class inside `job_card.dart`).
 
Applying the three criteria:
 
1. **Single, nameable responsibility** — ✅ "Displays job open/closed
   status." Five words, one job.
2. **Rendered in more than one place** — ✅ Beyond `JobCard`, this is
   very likely to reappear on an employer's listing-management
   dashboard, an application-tracking view, and possibly a compact
   list-row variant later in the course — anywhere a job's open/closed
   state needs a quick visual signal.
3. **Testable in isolation** — ✅ It depends only on a single
   `bool isOpen` parameter, not on `Job` or any parent widget state, so
   it can be widget-tested completely independently of `JobCard`.
**All three criteria are satisfied**, making this an unusually clear-cut
extraction.
 
**Cost of not extracting:** If left inline, testing the status-colour
logic would require standing up the entire `JobCard` (and by extension a
full `Job` instance) just to verify a boolean-to-colour mapping —
unnecessary test setup for what should be a trivial, isolated check. It
would also invite duplication: the next time a status indicator is
needed elsewhere in CareerHub, a developer would either copy-paste the
private `_StatusChip` logic (risking the two implementations silently
drifting apart over time) or rebuild it from scratch.


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
