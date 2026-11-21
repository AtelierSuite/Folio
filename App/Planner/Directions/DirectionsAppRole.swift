import Foundation

public enum DirectionsAppRole: Sendable, CaseIterable {
    /// Shows a place on a map.
    case maps
    /// Gives directions to a place.
    case navigation
}

public extension DirectionsApp {
    func supports(_ role: DirectionsAppRole) -> Bool {
        switch role {
        case .maps: appPlaceLink != nil || webPlaceLink != nil
        case .navigation: appLink != nil || webLink != nil
        }
    }

    func isAvailable(for role: DirectionsAppRole, isInstalled: Bool) -> Bool {
        guard supports(role) else { return false }
        let hasWebLink = switch role {
        case .maps: webPlaceLink != nil
        case .navigation: webLink != nil
        }
        return queryScheme == nil || isInstalled || hasWebLink
    }

    /// The stored app, or Apple Maps when it's gone or can't take this role.
    static func app(id: String?, for role: DirectionsAppRole) -> DirectionsApp {
        guard let app = id.flatMap(app(id:)), app.supports(role) else { return .appleMaps }
        return app
    }

    static func apps(for role: DirectionsAppRole) -> [DirectionsApp] {
        all.filter { $0.supports(role) }
    }
}
