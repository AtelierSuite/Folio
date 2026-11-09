import AppIntents
import WidgetKit

/// Folio's complications have nothing to set up, but watch faces only list intent-configured ones.
struct ComplicationConfigurationIntent: WidgetConfigurationIntent {
    static let title = LocalizedStringResource("Intent.Title", table: "Complications")
}
