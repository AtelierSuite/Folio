import Planner
import SwiftUI
import WidgetKit

struct WidgetColorBar: View {
    let color: PlannerColor

    var body: some View {
        RoundedRectangle(cornerRadius: 1.5)
            .fill(color.color)
            .frame(width: 3)
            .widgetAccentable()
    }
}
