import Planner
import SwiftUI

extension TimelineLayer {
    static func rainHighlights(_ highlights: [RainHighlight]) -> TimelineLayer {
        TimelineLayer(id: "weather.rain", placement: .aboveEntries) { context in
            TimelineRainHighlightsView(highlights: highlights, context: context)
        }
    }
}

struct TimelineRainHighlightsView: View {
    let highlights: [RainHighlight]
    let context: TimelineLayerContext

    var body: some View {
        TimelineSlotLayout(dayCount: context.days.count, hourHeight: context.hourHeight) {
            ForEach(highlights) { highlight in
                if let segment = context.days.segments(from: highlight.eventStart, to: highlight.eventEnd).first {
                    TimelineRainBadge(highlight: highlight, timeZone: context.days.calendar.timeZone)
                        .timelineSlot(TimelineSlot(segment))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

struct TimelineRainBadge: View {
    let highlight: RainHighlight
    let timeZone: TimeZone

    var body: some View {
        ViewThatFits(in: .horizontal) {
            label.labelStyle(.titleAndIcon)
            label.labelStyle(.iconOnly)
        }
        .lineLimit(1)
        .font(.system(size: 9, weight: .semibold))
        .monospacedDigit()
        .foregroundStyle(.white)
        .padding(.horizontal, 4)
        .padding(.vertical, 1)
        .background(Color.blue, in: Capsule())
        .padding(2)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityIdentifier("RainHighlight.\(highlight.eventID)")
    }

    private var label: some View {
        Label(WeatherFormatting.chance(highlight.precipitationChance), systemImage: "umbrella.fill")
    }

    private var accessibilityLabel: String {
        let chance = WeatherFormatting.chance(highlight.precipitationChance)
        let time = highlight.eventStart.formatted(Date.FormatStyle(time: .shortened, timeZone: timeZone))
        if let place = highlight.placeName {
            return String(format: String(localized: "Accessibility.RainAtPlace", table: "Weather"), chance, time, place)
        }
        return String(format: String(localized: "Accessibility.Rain", table: "Weather"), chance, time)
    }
}
