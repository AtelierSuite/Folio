import Foundation

/// The country a regional maps app works in. Elsewhere Folio falls back to another app.
public enum DirectionsServedArea: Sendable {
    case japan
    case korea
}
