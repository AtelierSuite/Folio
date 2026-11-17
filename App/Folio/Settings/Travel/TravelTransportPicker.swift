import Planner
import SwiftUI

struct TravelTransportPicker: View {
    @Binding var selection: TravelTransport
    let accessibilityIdentifier: String

    var body: some View {
        Picker(String(localized: "Settings.Transport", table: "LeaveAlerts"), selection: $selection) {
            ForEach(TravelTransport.allCases) { transport in
                Text(transport.title).tag(transport)
            }
        }
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}
