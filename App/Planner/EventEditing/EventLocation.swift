import Foundation

public struct EventLocation: Sendable, Hashable {
    public var title: String
    public var address: String?
    public var coordinate: EventCoordinate?

    public init(title: String, address: String? = nil, coordinate: EventCoordinate? = nil) {
        self.title = title
        self.address = address.flatMap { $0.isEmpty ? nil : $0 }
        self.coordinate = coordinate
    }

    public init?(text: String?, coordinate: EventCoordinate? = nil) {
        let lines = (text ?? "")
            .split(separator: "\n", maxSplits: 1)
            .map { $0.trimmingCharacters(in: .whitespaces) }
        guard let title = lines.first, !title.isEmpty else { return nil }
        self.init(title: title, address: lines.count > 1 ? lines[1] : nil, coordinate: coordinate)
    }

    public var text: String {
        [title, address].compactMap(\.self).joined(separator: "\n")
    }
}

public struct EventCoordinate: Sendable, Hashable {
    public var latitude: Double
    public var longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
