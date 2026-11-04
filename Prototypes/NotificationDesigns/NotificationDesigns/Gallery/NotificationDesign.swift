import SwiftUI

enum NotificationDesign: Int, CaseIterable, Identifiable {
    case current
    case centered
    case splitHeader
    case flightPath
    case agendaColumns
    case colorWash
    case capsules
    case dayTile
    case factGrid
    case ticket
    case titleFirst

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .current: "Current"
        case .centered: "1. Centered"
        case .splitHeader: "2. Split Header"
        case .flightPath: "3. Flight Path"
        case .agendaColumns: "4. Agenda Columns"
        case .colorWash: "5. Color Wash"
        case .capsules: "6. Capsules"
        case .dayTile: "7. Day Tile"
        case .factGrid: "8. Fact Grid"
        case .ticket: "9. Ticket"
        case .titleFirst: "10. Title First"
        }
    }

    // swiftlint:disable:next cyclomatic_complexity
    @ViewBuilder func content(for alert: SampleAlert) -> some View {
        switch self {
        case .current: CurrentDesign(alert: alert)
        case .centered: CenteredDesign(alert: alert)
        case .splitHeader: SplitHeaderDesign(alert: alert)
        case .flightPath: FlightPathDesign(alert: alert)
        case .agendaColumns: AgendaColumnsDesign(alert: alert)
        case .colorWash: ColorWashDesign(alert: alert)
        case .capsules: CapsulesDesign(alert: alert)
        case .dayTile: DayTileDesign(alert: alert)
        case .factGrid: FactGridDesign(alert: alert)
        case .ticket: TicketDesign(alert: alert)
        case .titleFirst: TitleFirstDesign(alert: alert)
        }
    }
}
