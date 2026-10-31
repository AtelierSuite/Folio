import Foundation

public enum AlternateCalendar: String, CaseIterable, Identifiable, Sendable {
    case chinese
    case korean
    case vietnamese
    case japanese
    case republicOfChina
    case buddhist
    case hebrew
    case islamic
    case islamicCivil
    case islamicUmmAlQura
    case persian
    case indian
    case vikram
    case bangla
    case gujarati
    case kannada
    case malayalam
    case marathi
    case odia
    case tamil
    case telugu
    case ethiopic
    case coptic

    public static let storageKey = "Calendar.AlternateCalendar"

    public var id: String { rawValue }

    public var identifier: Calendar.Identifier {
        switch self {
        case .chinese: .chinese
        case .korean: .dangi
        case .vietnamese: .vietnamese
        case .japanese: .japanese
        case .republicOfChina: .republicOfChina
        case .buddhist: .buddhist
        case .hebrew: .hebrew
        case .islamic: .islamic
        case .islamicCivil: .islamicCivil
        case .islamicUmmAlQura: .islamicUmmAlQura
        case .persian: .persian
        case .indian: .indian
        case .vikram: .vikram
        case .bangla: .bangla
        case .gujarati: .gujarati
        case .kannada: .kannada
        case .malayalam: .malayalam
        case .marathi: .marathi
        case .odia: .odia
        case .tamil: .tamil
        case .telugu: .telugu
        case .ethiopic: .ethiopicAmeteMihret
        case .coptic: .coptic
        }
    }

    public var sharesGregorianDays: Bool {
        switch self {
        case .japanese, .republicOfChina, .buddhist: true
        default: false
        }
    }

    public var isChineseLunisolar: Bool {
        switch self {
        case .chinese, .korean, .vietnamese: true
        default: false
        }
    }

    public func displayName(in locale: Locale) -> String {
        locale.localizedString(for: identifier) ?? rawValue
    }

    public static func sortedByName(in locale: Locale) -> [AlternateCalendar] {
        allCases.sorted {
            $0.displayName(in: locale).localizedStandardCompare($1.displayName(in: locale)) == .orderedAscending
        }
    }
}
