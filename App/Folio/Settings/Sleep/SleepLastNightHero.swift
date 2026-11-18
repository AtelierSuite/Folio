import Planner
import SwiftUI

struct SleepLastNightHero: View {
    let lastNight: SleepSession

    var body: some View {
        Section {
            content
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("SleepLastNight")
        }
    }

    private var content: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "bed.double.fill")
                Text(String(localized: "Settings.LastNight", table: "Sleep"))
            }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(Duration.seconds(lastNight.asleepDuration)
                .formatted(.units(allowed: [.hours, .minutes], width: .narrow)))
                .font(.system(size: 56, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            HStack(spacing: 16) {
                timeLabel(lastNight.interval.start, systemImage: "moon.fill")
                timeLabel(lastNight.interval.end, systemImage: "sun.max.fill")
            }
                .font(.headline)
            if let source = lastNight.primarySource {
                Text(source.name)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }

    private func timeLabel(_ date: Date, systemImage: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .foregroundStyle(.secondary)
            Text(date.formatted(date: .omitted, time: .shortened))
                .monospacedDigit()
        }
    }
}
