import SwiftUI

extension View {
    func calendarMonthTextFit() -> some View {
        modifier(CalendarMonthTextFit())
    }
}

private struct CalendarMonthTextFit: ViewModifier {
    @AppStorage(TimelineSettings.compressesTextKey) private var compressesText = false

    private static let minimumScaleFactor: CGFloat = 0.6

    func body(content: Content) -> some View {
        content
            .minimumScaleFactor(compressesText ? Self.minimumScaleFactor : 1)
            .allowsTightening(compressesText)
    }
}
