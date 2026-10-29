import Foundation

extension DateComponents {
    var resolvedDate: Date? {
        (calendar ?? .current).date(from: self)
    }
}
