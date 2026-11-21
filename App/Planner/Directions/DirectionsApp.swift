import Foundation

/// A maps app Folio can hand directions to. Each app is a static instance in `Directions/Apps`.
public struct DirectionsApp: Sendable, Identifiable {
    public typealias Link = @Sendable (DirectionsRequest) -> URL?
    public typealias PlaceLink = @Sendable (DirectionsDestination) -> URL?

    /// Stored in settings, so it must never change once shipped.
    public let id: String
    /// Checked with `canOpenURL`, so it must also be listed in `LSApplicationQueriesSchemes`.
    /// `nil` for apps that are always there, such as Apple Maps.
    public let queryScheme: String?
    public let transports: Set<TravelTransport>
    public let servedArea: DirectionsServedArea?
    /// Opens the installed app. Returns `nil` when the app can't route to this destination.
    let appLink: Link?
    /// Opens the website, or the app through a universal link, when the app isn't installed.
    let webLink: Link?
    /// Shows the place itself rather than a route to it.
    let appPlaceLink: PlaceLink?
    let webPlaceLink: PlaceLink?

    init(
        id: String,
        queryScheme: String?,
        transports: Set<TravelTransport> = Set(TravelTransport.allCases),
        servedArea: DirectionsServedArea? = nil,
        appLink: Link? = nil,
        webLink: Link? = nil,
        appPlaceLink: PlaceLink? = nil,
        webPlaceLink: PlaceLink? = nil
    ) {
        self.id = id
        self.queryScheme = queryScheme
        self.transports = transports
        self.servedArea = servedArea
        self.appLink = appLink
        self.webLink = webLink
        self.appPlaceLink = appPlaceLink
        self.webPlaceLink = webPlaceLink
    }

    public func url(for request: DirectionsRequest, isInstalled: Bool) -> URL? {
        if let transport = request.transport, !transports.contains(transport) {
            return nil
        }
        if isInstalled || queryScheme == nil, let url = appLink?(request) {
            return url
        }
        return webLink?(request)
    }

    /// Directions in the preferred app, or in Apple Maps when that app can't take this request.
    public static func url(
        for request: DirectionsRequest,
        preferring preferred: DirectionsApp,
        isInstalled: Bool
    ) -> URL? {
        preferred.url(for: request, isInstalled: isInstalled)
            ?? appleMaps.url(for: request, isInstalled: true)
    }

    public func placeURL(for destination: DirectionsDestination, isInstalled: Bool) -> URL? {
        if isInstalled || queryScheme == nil, let url = appPlaceLink?(destination) {
            return url
        }
        return webPlaceLink?(destination)
    }

    /// The place in the preferred app, or in Apple Maps when that app can't show it.
    public static func placeURL(
        for destination: DirectionsDestination,
        preferring preferred: DirectionsApp,
        isInstalled: Bool
    ) -> URL? {
        preferred.placeURL(for: destination, isInstalled: isInstalled)
            ?? appleMaps.placeURL(for: destination, isInstalled: true)
    }
}

extension DirectionsApp: Hashable {
    public static func == (lhs: DirectionsApp, rhs: DirectionsApp) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
