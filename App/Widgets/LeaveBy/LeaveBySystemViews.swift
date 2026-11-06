#if os(iOS)
import Planner
import SwiftUI
import WidgetKit

struct LeaveBySmallView: View {
    let countdown: LeaveByCountdown

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 3) {
                Image(systemName: countdown.transportSymbol)
                Text(verbatim: countdown.headline)
            }
            .font(.caption.weight(.semibold))
            .foregroundStyle(countdown.color)
            .widgetAccentable()
            Text(verbatim: countdown.value)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
            Spacer(minLength: 0)
            Text(verbatim: countdown.leaveBy.event.title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
            HStack(spacing: 4) {
                Text(verbatim: "\(countdown.arrivalText) · \(countdown.travelText)")
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                if countdown.leaveBy.needsUmbrella {
                    Image(systemName: "umbrella.fill")
                        .foregroundStyle(.blue)
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

struct LeaveByMediumView: View {
    let countdown: LeaveByCountdown
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(verbatim: countdown.headline)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(countdown.color)
                        .widgetAccentable()
                    Text(verbatim: countdown.value)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                }
                Spacer(minLength: 8)
                LeaveByDestination(countdown: countdown)
            }
            Spacer(minLength: 0)
            LeaveByRouteBar(countdown: countdown, date: date)
        }
    }
}

private struct LeaveByDestination: View {
    let countdown: LeaveByCountdown

    var body: some View {
        VStack(alignment: .trailing, spacing: 1) {
            Text(verbatim: countdown.leaveBy.event.title)
                .font(.subheadline.weight(.semibold))
            if let location = countdown.leaveBy.event.location {
                Text(verbatim: location)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if countdown.leaveBy.needsUmbrella {
                HStack(spacing: 3) {
                    Image(systemName: "umbrella.fill")
                    Text(verbatim: String(localized: "LeaveBy.Rain", table: "Widgets"))
                }
                .font(.caption2.weight(.medium))
                .foregroundStyle(.blue)
            }
        }
        .lineLimit(1)
    }
}

/// The wait until leaving, then the journey, ending when the event starts.
private struct LeaveByRouteBar: View {
    let countdown: LeaveByCountdown
    let date: Date

    private var waitShare: Double {
        let total = countdown.leaveBy.event.startDate.timeIntervalSince(date)
        let wait = max(countdown.leaveBy.timeUntilLeaving(at: date), 0)
        return min(max(wait / max(total, 1), 0.12), 0.8)
    }

    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { proxy in
                HStack(spacing: 2) {
                    Capsule()
                        .fill(.quaternary)
                        .frame(width: proxy.size.width * waitShare)
                    Capsule()
                        .fill(countdown.color)
                        .widgetAccentable()
                }
            }
            .frame(height: 8)
            HStack {
                Text(verbatim: String(localized: "UpNext.Now", table: "Widgets"))
                Spacer()
                Text(verbatim: String(
                    format: String(localized: "LeaveBy.LeaveAt %@", table: "Widgets"),
                    WidgetEventTimeText.time(countdown.leaveBy.leaveDate)
                ))
                .fontWeight(.semibold)
                Spacer()
                Text(verbatim: String(
                    format: String(localized: "LeaveBy.ArriveAt %@", table: "Widgets"), countdown.arrivalText
                ))
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
    }
}
#endif
