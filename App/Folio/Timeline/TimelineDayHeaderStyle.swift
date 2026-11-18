import SwiftUI

enum TimelineDayHeaderStyle {
    case stacked
    case inline
}

extension EnvironmentValues {
    @Entry var timelineDayHeaderStyle: TimelineDayHeaderStyle = .stacked
}
