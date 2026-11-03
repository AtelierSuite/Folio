import Foundation

enum StandaloneAlarmComposerFailure {
    case pastDate
    case failed

    var title: String {
        switch self {
        case .pastDate: String(localized: "Composer.PastDate.Title", table: "StandaloneAlarms")
        case .failed: String(localized: "Composer.Failed.Title", table: "StandaloneAlarms")
        }
    }

    var message: String {
        switch self {
        case .pastDate: String(localized: "Composer.PastDate.Message", table: "StandaloneAlarms")
        case .failed: String(localized: "Composer.Failed.Message", table: "StandaloneAlarms")
        }
    }
}
