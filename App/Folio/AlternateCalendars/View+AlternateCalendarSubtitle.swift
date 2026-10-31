import Planner
import SwiftUI

struct AlternateCalendarSubtitle: ViewModifier {
    @Environment(\.alternateCalendarFormatter) private var formatter
    let date: Date
    let calendar: Calendar

    func body(content: Content) -> some View {
        content.navigationSubtitle(subtitle)
    }

    private var subtitle: String {
        guard let formatter, let month = calendar.dateInterval(of: .month, for: date) else { return "" }
        return formatter.monthTitle(for: month)
    }
}

extension View {
    func alternateCalendarSubtitle(for date: Date, in calendar: Calendar) -> some View {
        modifier(AlternateCalendarSubtitle(date: date, calendar: calendar))
    }
}
