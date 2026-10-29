import SwiftUI

/// Filled from the weather cache in the App Group once weather (#27) lands; widgets never fetch weather.
struct WidgetWeatherSlot: View {
    let date: Date

    var body: some View {
        EmptyView()
    }
}
