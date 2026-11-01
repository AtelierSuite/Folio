import Planner
import SwiftUI

struct SnoozeDurationPicker: View {
    let title: String
    @Binding var minutes: Int

    var body: some View {
        Picker(title, selection: $minutes) {
            ForEach(choices, id: \.self) { choice in
                Text(NotificationSnoozeDurations.title(forMinutes: choice)).tag(choice)
            }
        }
    }

    private var choices: [Int] {
        NotificationSnoozeDurations.choices.contains(minutes)
            ? NotificationSnoozeDurations.choices
            : (NotificationSnoozeDurations.choices + [minutes]).sorted()
    }
}
