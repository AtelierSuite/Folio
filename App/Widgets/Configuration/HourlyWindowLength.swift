import AppIntents

nonisolated enum HourlyWindowLength: String, AppEnum {
    case three
    case five
    case eight

    static let typeDisplayRepresentation = TypeDisplayRepresentation(
        name: LocalizedStringResource("Configuration.Hours", table: "Widgets")
    )

    static let caseDisplayRepresentations: [HourlyWindowLength: DisplayRepresentation] = [
        .three: DisplayRepresentation(title: LocalizedStringResource("Configuration.Hours.Three", table: "Widgets")),
        .five: DisplayRepresentation(title: LocalizedStringResource("Configuration.Hours.Five", table: "Widgets")),
        .eight: DisplayRepresentation(title: LocalizedStringResource("Configuration.Hours.Eight", table: "Widgets"))
    ]

    var hourCount: Int {
        switch self {
        case .three: 3
        case .five: 5
        case .eight: 8
        }
    }
}
