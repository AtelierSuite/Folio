# WidgetLab

A throwaway harness for trying widget ideas without touching Folio's `Widgets` target. It is a plain iOS app that draws each idea at real widget sizes from sample data, with a time slider and scenarios. Nothing here links `Planner` or ships.

```sh
xcodegen generate
open WidgetLab.xcodeproj
```

The tests cover the logic, drive the gallery controls, and write contact sheets of every widget in light and dark:

```sh
TEST_RUNNER_LAB_OUTPUT=/path/to/folder xcodebuild test -project WidgetLab.xcodeproj -scheme WidgetLab -destination "id=<UDID>"
```

Strings are not localized, and the gallery draws plain SwiftUI views rather than real WidgetKit timelines. Anything promoted to `App/Widgets` needs both.
