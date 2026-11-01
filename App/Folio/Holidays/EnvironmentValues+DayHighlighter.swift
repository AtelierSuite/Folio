import Planner
import SwiftUI

extension EnvironmentValues {
    @Entry var dayHighlighter: DayHighlighter = .none
}

extension Color {
    static let dayHighlight = Color.red
}
