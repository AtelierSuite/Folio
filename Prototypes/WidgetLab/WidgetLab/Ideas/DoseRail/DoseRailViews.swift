import SwiftUI

private extension LabSnapshot {
    var sortedDoses: [LabDose] { doses.sorted { $0.time < $1.time } }
    var nextDose: LabDose? { sortedDoses.first { $0.time > now } }
    var takenCount: Int { doses.filter { $0.status(at: now) == .taken }.count }
    var doseTimes: [Date] { Array(Set(doses.map(\.time))).sorted() }
    var medicationNames: [String] {
        doses.map(\.medication).reduce(into: []) { names, name in
            if !names.contains(name) { names.append(name) }
        }
    }
}

struct DosePill: View {
    let status: LabDoseStatus
    var isNext = false

    var body: some View {
        ZStack {
            shape
            if status == .skipped {
                Image(systemName: "xmark").font(.system(size: 7, weight: .bold)).foregroundStyle(.secondary)
            }
        }
        .frame(width: 22, height: 11)
        .overlay {
            if isNext {
                Capsule().stroke(Color("AccentColor"), lineWidth: 1.5).padding(-2.5)
            }
        }
    }

    @ViewBuilder
    private var shape: some View {
        switch status {
        case .taken:
            Capsule().fill(.teal)
        case .skipped:
            Capsule().fill(.quaternary)
        case .notLogged:
            Capsule().stroke(.orange, lineWidth: 1.5)
        case .estimated:
            Capsule().stroke(.secondary, style: StrokeStyle(lineWidth: 1.5, dash: [3, 2]))
        }
    }
}

private struct MedicationRow: View {
    let name: String
    let snapshot: LabSnapshot

    private var doses: [LabDose] {
        snapshot.sortedDoses.filter { $0.medication == name }
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(name)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .frame(width: 86, alignment: .leading)
            ForEach(snapshot.doseTimes, id: \.self) { time in
                VStack(spacing: 2) {
                    if let dose = doses.first(where: { $0.time == time }) {
                        DosePill(status: dose.status(at: snapshot.now), isNext: dose.id == snapshot.nextDose?.id)
                        Text(LabFormat.time(dose.time))
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 38)
            }
            Spacer(minLength: 0)
        }
    }
}

struct DoseRailSmallView: View {
    let snapshot: LabSnapshot

    var body: some View {
        if snapshot.doses.isEmpty {
            LabEmptyText("No doses scheduled")
        } else {
            VStack(alignment: .leading, spacing: 2) {
                Label("Next dose", systemImage: "pills.fill")
                    .labelStyle(TightLabelStyle())
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.teal)
                Text(snapshot.nextDose.map { LabFormat.time($0.time) } ?? "Done")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text(snapshot.nextDose?.medication ?? "All doses passed")
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                Spacer(minLength: 0)
                HStack(spacing: 3) {
                    ForEach(snapshot.sortedDoses) { dose in
                        DosePill(status: dose.status(at: snapshot.now))
                            .scaleEffect(0.82)
                            .frame(width: 19)
                    }
                }
                Text("Estimated times").font(.system(size: 9)).foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
        }
    }
}

struct DoseRailMediumView: View {
    let snapshot: LabSnapshot

    var body: some View {
        LabTitleBarLayout {
            Text("Medications")
            Spacer(minLength: 0)
            if !snapshot.doses.isEmpty {
                Text("\(snapshot.takenCount) of \(snapshot.doses.count) taken").fontWeight(.regular)
            }
        } content: {
            if snapshot.doses.isEmpty {
                LabEmptyText("No doses scheduled")
            } else {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(snapshot.medicationNames.prefix(3), id: \.self) { name in
                        MedicationRow(name: name, snapshot: snapshot)
                    }
                    Spacer(minLength: 0)
                    Text("Dashed times are estimates").font(.system(size: 9)).foregroundStyle(.tertiary)
                }
            }
        }
    }
}

struct DoseRailRectangularView: View {
    let snapshot: LabSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let next = snapshot.nextDose {
                Text("~\(LabFormat.time(next.time)) \(next.medication)").font(.headline).minimumScaleFactor(0.7)
                Text(next.amount).font(.caption).opacity(0.7)
            } else {
                Text(snapshot.doses.isEmpty ? "No doses today" : "No more doses").font(.headline)
            }
            if !snapshot.doses.isEmpty {
                Text("\(snapshot.takenCount) of \(snapshot.doses.count) taken").font(.caption).opacity(0.7)
            }
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
