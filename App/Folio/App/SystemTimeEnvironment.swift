import Planner
import SwiftUI

struct SystemTimeEnvironment: ViewModifier {
    let systemTime: SystemTimeObserver

    func body(content: Content) -> some View {
        content
            .environment(systemTime)
            .environment(\.calendar, systemTime.calendar)
            .environment(\.timeZone, systemTime.timeZone)
    }
}

extension View {
    func followsSystemTime(_ systemTime: SystemTimeObserver) -> some View {
        modifier(SystemTimeEnvironment(systemTime: systemTime))
    }
}
