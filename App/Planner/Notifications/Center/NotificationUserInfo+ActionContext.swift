import Foundation

extension NotificationUserInfo {
    static let meetingURLKey = "meetingURL"
    static let placeNameKey = "placeName"
    static let latitudeKey = "latitude"
    static let longitudeKey = "longitude"

    static func make(for context: NotificationActionContext) -> [String: Any] {
        var userInfo: [String: Any] = [:]
        userInfo[meetingURLKey] = context.meetingURL?.absoluteString
        userInfo[placeNameKey] = context.place?.name
        userInfo[latitudeKey] = context.place?.coordinate?.latitude
        userInfo[longitudeKey] = context.place?.coordinate?.longitude
        return userInfo
    }

    public static func actionContext(from userInfo: [AnyHashable: Any]) -> NotificationActionContext {
        let coordinate: PlannerCoordinate? = if let latitude = userInfo[latitudeKey] as? Double,
            let longitude = userInfo[longitudeKey] as? Double {
            PlannerCoordinate(latitude: latitude, longitude: longitude)
        } else {
            nil
        }
        return NotificationActionContext(
            meetingURL: (userInfo[meetingURLKey] as? String).flatMap(URL.init(string:)),
            place: NotificationPlace(name: userInfo[placeNameKey] as? String, coordinate: coordinate)
        )
    }
}
