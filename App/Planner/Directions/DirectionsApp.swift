import Foundation

/// A maps app Folio can hand directions to. Each app is a static instance in `Directions/Apps`.
public struct DirectionsApp: Sendable, Identifiable {
    public typealias Link = @Sendable (DirectionsRequest) -> URL?

    /// Stored in settings, so it must never change once shipped.
    public let id: String
    /// Checked with `canOpenURL`, so it must also be listed in `LSApplicationQueriesSchemes`.
    /// `nil` for apps that are always there, such as Apple Maps.
    public let queryScheme: String?
    public let transports: Set<TravelTransport>
    /// Opens the installed app. Returns `nil` when the app can't route to this destination.
    let appLink: Link?
    /// Opens the website, or the app through a universal link, when the app isn't installed.
    let webLink: Link?

    init(
        id: String,
        queryScheme: String?,
        transports: Set<TravelTransport> = Set(TravelTransport.allCases),
        appLink: Link? = nil,
        webLink: Link? = nil
    ) {
        self.id = id
        self.queryScheme = queryScheme
        self.transports = transports
        self.appLink = appLink
        self.webLink = webLink
    }

    public func isAvailable(isInstalled: Bool) -> Bool {
        queryScheme == nil || isInstalled || webLink != nil
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
}

extension DirectionsApp: Hashable {
    public static func == (lhs: DirectionsApp, rhs: DirectionsApp) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
