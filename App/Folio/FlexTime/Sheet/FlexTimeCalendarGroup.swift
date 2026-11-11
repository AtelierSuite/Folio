import Planner
import SwiftUI

struct FlexTimeCalendarGroup: View {
    @Environment(CalendarStore.self) private var store
    let calendarIdentifier: String
    let events: [CalendarEvent]
    let delay: TimeInterval
    @Binding var isIncluded: Bool

    var body: some View {
        VStack(spacing: 12) {
            Button {
                isIncluded.toggle()
            } label: {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Image(systemName: isIncluded ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isIncluded ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isIncluded ? .isSelected : [])
            .accessibilityIdentifier("FlexTimeCalendar.\(title)")
            ForEach(events) { event in
                FlexTimeEventPreviewRow(event: event, delay: isIncluded ? delay : 0)
                    .opacity(isIncluded ? 1 : 0.5)
            }
        }
        .padding(16)
        .background(.fill.tertiary, in: .rect(cornerRadius: 16))
    }

    private var title: String {
        store.calendar(withIdentifier: calendarIdentifier)?.title
            ?? String(localized: "Prompt.Calendar.Unknown", table: "FlexTime")
    }
}
