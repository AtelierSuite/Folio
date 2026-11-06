import SwiftUI

private extension LabSnapshot {
    var nextPreparedMeeting: LabEvent? {
        events.filter { $0.note != nil && $0.end > now }.min { $0.start < $1.start }
    }

    func startsText(for event: LabEvent) -> String {
        if event.start <= now { return "Happening now" }
        return "In \(LabFormat.duration(minutes: LabFormat.minutes(from: now, to: event.start)))"
    }
}

private struct AttendeeStack: View {
    let attendees: [LabAttendee]

    var body: some View {
        HStack(spacing: 2) {
            ForEach(attendees) { attendee in
                Text(attendee.initials)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 22, height: 22)
                    .background(color(for: attendee.response), in: .circle)
            }
        }
    }

    private func color(for response: LabAttendeeResponse) -> Color {
        switch response {
        case .accepted: .green
        case .tentative: .orange
        case .noReply: .gray
        }
    }
}

private struct JoinPill: View {
    let meeting: LabMeeting

    var body: some View {
        Label("Join", systemImage: "video.fill")
            .labelStyle(TightLabelStyle())
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(meeting.brandColor, in: .capsule)
    }
}

private struct ChecklistRow: View {
    let item: LabChecklistItem

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(item.isDone ? AnyShapeStyle(Color("AccentColor")) : AnyShapeStyle(.secondary))
            Text(item.text)
                .foregroundStyle(item.isDone ? .secondary : .primary)
                .lineLimit(1)
        }
        .font(.caption)
    }
}

struct MeetingPrepMediumView: View {
    let snapshot: LabSnapshot

    var body: some View {
        if let event = snapshot.nextPreparedMeeting, let note = event.note {
            LabTitleBarLayout {
                Text(event.title)
                Spacer(minLength: 0)
                Text(snapshot.startsText(for: event)).fontWeight(.regular)
            } content: {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(note.checklist.filter { !$0.isDone }.prefix(2)) { ChecklistRow(item: $0) }
                    Text(note.summary).font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                    Spacer(minLength: 0)
                    HStack {
                        AttendeeStack(attendees: event.attendees)
                        Spacer(minLength: 0)
                        if let meeting = event.meeting { JoinPill(meeting: meeting) }
                    }
                }
            }
        } else {
            LabEmptyText("No meetings with notes coming up")
        }
    }
}

struct MeetingPrepLargeView: View {
    let snapshot: LabSnapshot

    var body: some View {
        if let event = snapshot.nextPreparedMeeting, let note = event.note {
            LabTitleBarLayout {
                Text(event.title)
                Spacer(minLength: 0)
                Text(snapshot.startsText(for: event)).fontWeight(.regular)
            } content: {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(LabFormat.time(event.start))–\(LabFormat.time(event.end))")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(event.tint)
                    Text(note.title).font(.headline)
                    Text(note.summary).font(.caption).foregroundStyle(.secondary).lineLimit(3)
                    Divider()
                    ForEach(note.checklist) { ChecklistRow(item: $0) }
                    Spacer(minLength: 0)
                    Text(responseSummary(event)).font(.caption2).foregroundStyle(.secondary)
                    HStack {
                        AttendeeStack(attendees: event.attendees)
                        Spacer(minLength: 0)
                        if let meeting = event.meeting { JoinPill(meeting: meeting) }
                    }
                }
            }
        } else {
            LabEmptyText("No meetings with notes coming up")
        }
    }

    private func responseSummary(_ event: LabEvent) -> String {
        let going = event.attendees.filter { $0.response == .accepted }.count
        let waiting = event.attendees.filter { $0.response != .accepted }.count
        return "\(going) going, \(waiting) not confirmed"
    }
}
