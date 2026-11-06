import Planner
import SwiftUI
import WidgetKit

struct WidgetColorBar: View {
    let color: PlannerColor

    var body: some View {
        Rectangle()
            .fill(color.color)
            .frame(width: 3)
            .widgetAccentable()
    }
}
