import Foundation

extension NotificationUserInfo {
    static let placeNameKey = "placeName"
    static let latitudeKey = "latitude"
    static let longitudeKey = "longitude"

    static func make(for place: NotificationPlace?) -> [String: Any] {
        var userInfo: [String: Any] = [:]
        userInfo[placeNameKey] = place?.name
        userInfo[latitudeKey] = place?.coordinate?.latitude
        userInfo[longitudeKey] = place?.coordinate?.longitude
        return userInfo
    }

    public static func place(from userInfo: [AnyHashable: Any]) -> NotificationPlace? {
        let coordinate: PlannerCoordinate? = if let latitude = userInfo[latitudeKey] as? Double,
            let longitude = userInfo[longitudeKey] as? Double {
            PlannerCoordinate(latitude: latitude, longitude: longitude)
        } else {
            nil
        }
        return NotificationPlace(name: userInfo[placeNameKey] as? String, coordinate: coordinate)
    }
}
