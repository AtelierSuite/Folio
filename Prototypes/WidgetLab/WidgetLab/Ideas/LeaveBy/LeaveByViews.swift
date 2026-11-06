import SwiftUI

private extension LeavePlan {
    var headline: String { minutesUntilLeaving > 0 ? "Leave in" : "Leave now" }
    var countdown: String {
        minutesUntilLeaving > 0 ? LabFormat.duration(minutes: minutesUntilLeaving) : "Late \(LabFormat.duration(minutes: -minutesUntilLeaving))"
    }
    var urgencyColor: Color {
        switch urgency {
        case .relaxed: event.tint
        case .soon: .orange
        case .overdue: .red
        }
    }
    var travelText: String { "\(LabFormat.duration(minutes: event.travelMinutes ?? 0)) drive" }
}

struct LeaveBySmallView: View {
    let snapshot: LabSnapshot

    var body: some View {
        if let plan = LeavePlanner.nextPlan(in: snapshot) {
            VStack(alignment: .leading, spacing: 2) {
                Label(plan.headline, systemImage: "car.fill")
                    .labelStyle(TightLabelStyle())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(plan.urgencyColor)
                Text(plan.countdown)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Text(plan.event.title)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Text("\(LabFormat.time(plan.event.start)) · \(plan.travelText)")
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    if plan.needsUmbrella {
                        Image(systemName: "umbrella.fill").foregroundStyle(.blue)
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
        } else {
            LabEmptyText("Nowhere to be today")
        }
    }
}

struct LeaveByMediumView: View {
    let snapshot: LabSnapshot

    var body: some View {
        if let plan = LeavePlanner.nextPlan(in: snapshot) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(plan.headline)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(plan.urgencyColor)
                        Text(plan.countdown)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .lineLimit(1)
                    }
                    Spacer(minLength: 8)
                    VStack(alignment: .trailing, spacing: 1) {
                        Text(plan.event.title).font(.subheadline.weight(.semibold))
                        Text(plan.event.location ?? "").font(.caption).foregroundStyle(.secondary)
                        if plan.needsUmbrella {
                            Label("Rain on the way", systemImage: "umbrella.fill")
                                .labelStyle(TightLabelStyle())
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.blue)
                        }
                    }
                    .lineLimit(1)
                }
                Spacer(minLength: 0)
                LeaveRouteBar(plan: plan, now: snapshot.now)
            }
            .padding(14)
        } else {
            LabEmptyText("Nowhere to be today")
        }
    }
}

struct LeaveRouteBar: View {
    let plan: LeavePlan
    let now: Date

    private var waitShare: Double {
        let wait = max(plan.leaveAt.timeIntervalSince(now), 0)
        return min(max(wait / max(plan.event.start.timeIntervalSince(now), 1), 0.12), 0.8)
    }

    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { proxy in
                HStack(spacing: 2) {
                    Capsule().fill(.quaternary).frame(width: proxy.size.width * waitShare)
                    Capsule().fill(plan.urgencyColor)
                }
            }
            .frame(height: 8)
            HStack {
                Text("Now")
                Spacer()
                Text("Leave \(LabFormat.time(plan.leaveAt))").fontWeight(.semibold)
                Spacer()
                Text("Arrive \(LabFormat.time(plan.event.start))")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
    }
}

struct LeaveByCircularView: View {
    let snapshot: LabSnapshot

    var body: some View {
        if let plan = LeavePlanner.nextPlan(in: snapshot) {
            Gauge(value: Double(max(60 - plan.minutesUntilLeaving, 0)), in: 0...60) {
                Image(systemName: "car.fill")
            } currentValueLabel: {
                Text("\(max(plan.minutesUntilLeaving, 0))")
            }
            .gaugeStyle(.accessoryCircular)
        } else {
            Image(systemName: "car")
        }
    }
}

struct LeaveByRectangularView: View {
    let snapshot: LabSnapshot

    var body: some View {
        if let plan = LeavePlanner.nextPlan(in: snapshot) {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(plan.headline) \(plan.minutesUntilLeaving > 0 ? plan.countdown : "")")
                    .font(.headline)
                Text(plan.event.title).font(.caption)
                Text(plan.needsUmbrella ? "\(plan.travelText) · Umbrella" : plan.travelText)
                    .font(.caption)
                    .opacity(0.7)
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Text("No trips today").font(.caption)
        }
    }
}
