import SwiftUI
import WidgetKit

extension View {
    func folioWidgetContainer() -> some View {
        tint(Color("AccentColor"))
            .containerBackground(.fill.tertiary, for: .widget)
    }
}
