# Layout

- `Folio.xcodeproj`: one SwiftUI multiplatform project (iOS, iPadOS and native macOS, not Mac Catalyst). Minimum OS 26.1.
- `Folio`: the app target. Views and app-only glue, grouped in one folder per feature (`Calendar`, `Notes`, `Search`, `Settings`, ...). Default actor isolation is `MainActor`.
- `Planner`: the framework holding the core calendar, reminders and notes logic (EventKit data layer, timeline layout, notes storage, Markdown, scheduling, search index, capability layer). Anything the widgets, App Intents or tests need lives here, not in the app. Default actor isolation is `nonisolated`. It is linked by the app and the widget extension, so it must stay extension-safe (`APPLICATION_EXTENSION_API_ONLY`).
- `Widgets`: the widget extension (widgets, Live Activity, Control Center controls).
- `PlannerTests`: Swift Testing unit tests for `Planner`.
- `FolioUITests`: XCTest UI tests for the app.
- `Scripts`: developer scripts, such as `mac-vm.sh` for testing in the Mac VM.

Every target folder is a synchronized folder: add, move and delete files on disk and Xcode picks them up. Only touch `project.pbxproj` for build settings, capabilities or new targets, and keep those edits small.

Shared identifiers:
- Bundle ID `com.tsubuzaki.Folio`, widgets `com.tsubuzaki.Folio.Widgets`, framework `com.tsubuzaki.Folio.Planner`.
- App Group `group.com.tsubuzaki.Folio` (`AppGroup` in `Planner`).
- URL scheme `folio://`.
- Entitlements: `Folio/Folio.entitlements` is used on macOS and `Folio/Folio-iOS.entitlements` on iOS and iPadOS (it adds HealthKit). Add shared entitlements to both files.
- Signed macOS builds need the iCloud container registered on the team, so build macOS with `CODE_SIGNING_ALLOWED=NO` when you only need to compile.
- Feature availability per device goes through `PlatformCapabilities` (in `Planner`, injected as `\.platformCapabilities`). Never check the platform ad hoc to hide a feature.

# Rules

1. Do not add verbose comments.
   - Only write comments or doc comments when they are absolutely necessary to explain a gotcha, SwiftUI bug, or workaround.
   - Opt for self explanatory class/struct/enum/function names instead.
2. Do not create large .swift files.
   - Separate large classes/enums/structs using extensions, grouped into its own folder.
   - Avoid view builders if they are long. Separate the views and create their own .swift files.
3. Do not use single or double letter variable names. Spell all variable names out in full (time instead of t, xPosition instead of x).
4. Localize every user-facing string.
   - Strings live in one string catalog per feature in `Folio/Strings` (for example `Calendar.xcstrings`), looked up with `String(localized: "Key", table: "Calendar")`. Create a new catalog for a new feature instead of growing someone else's. `Planner` and `Widgets` keep their own catalogs in their own `Strings` folder.
   - Usage descriptions and other Info.plist strings go in `Folio/Strings/InfoPlist.xcstrings`.
   - Translate every key into all the catalog languages: en, ja, zh-Hans, zh-Hant, ko, fr, de, it, nl, vi.
   - Generate the object for each string in a separate file, then use Python to set the object as the value for localization keys in the xcstrings file. Do not make large edits, and clean up the working files afterwards.
5. Ensure that you properly mark out MainActor or nonisolated functions to comply with Swift 6 concurrency checking.
6. Ensure that you fix all SwiftLint errors (`swiftlint` from this folder), except when:
   - log(:_, :_) patterns are concerned - use // swiftlint:disable:next line_length to disable warnings/errors for these lines.
   - Identifier names are deliberately short - use // swiftlint:disable:this identifier_name to disable warnings/errors.
   - iCloud, iPhone, or iPad is the first name in the type - use // swiftlint:disable:next type_name to disable warnings/errors.
7. Request each permission only when the user first touches the feature that needs it, and give every feature an empty or denied state.

# Testing

- Never run or test the app on this Mac directly.
- iOS and iPadOS: use the simulator you were assigned (or create your own named `Folio - <purpose>`). Use your own `-derivedDataPath` under `/tmp` so parallel builds don't collide.
  - Build: `xcodebuild -project Folio.xcodeproj -scheme Folio -destination "id=<UDID>" -derivedDataPath <path> build`
  - Tests: same command with `test`. Add unit tests in `PlannerTests` for logic you add to `Planner`.
  - Check UI changes by installing on the simulator and taking a screenshot (`xcrun simctl io <UDID> screenshot`).
- macOS: test in the Parallels VM named `macOS` through `Scripts/mac-vm.sh`, never on the host. The VM is shared by every agent, so:
  - Take the lock first with `Scripts/mac-vm.sh acquire "<your thread or PR>"`. It waits until the VM is free.
  - `deploy` builds, signs ad hoc, copies the app into the VM and launches it. `capture <file>` takes a screenshot. `run '<command>'` runs a shell command in the VM (UI scripting with `osascript` works there; the VM UI is in Japanese).
  - Always `release` as soon as you are done, even if a step failed.
  - The VM build has no provisioning profile, so iCloud, WeatherKit, HealthKit and Time Sensitive notifications can't be tested there.
