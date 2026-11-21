import Foundation

/// Who a regional app is listed for, by the device's region or language.
public enum DirectionsAudience: Sendable {
    case korean
    case simplifiedChinese

    public func includes(_ locale: Locale) -> Bool {
        switch self {
        case .korean:
            locale.region == .southKorea || locale.language.languageCode == .korean
        case .simplifiedChinese:
            locale.region == .chinaMainland || locale.language.script == .hanSimplified
        }
    }
}
