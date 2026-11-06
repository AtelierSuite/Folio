import SwiftUI

private struct AttentionRow: View {
    let item: AttentionItem

    private var symbol: String {
        switch item.kind {
        case .invitation: "envelope.fill"
        case .conflict: "exclamationmark.triangle.fill"
        case .overdueReminder: "circle"
        }
    }

    private var actionSymbol: String? {
        item.kind == .overdueReminder ? nil : "chevron.right"
    }

    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: symbol)
                .font(.subheadline)
                .foregroundStyle(item.tint)
                .frame(width: 18)
            VStack(alignment: .leading, spacing: 0) {
                Text(item.title).font(.caption.weight(.semibold))
                Text(item.detail).font(.caption2).foregroundStyle(.secondary)
            }
            .lineLimit(1)
            Spacer(minLength: 0)
            if let actionSymbol {
                Image(systemName: actionSymbol).font(.caption2.weight(.semibold)).foregroundStyle(.tertiary)
            }
        }
    }
}

private struct AttentionList: View {
    let snapshot: LabSnapshot
    let limit: Int

    private var items: [AttentionItem] { AttentionCollector.items(in: snapshot) }

    var body: some View {
        LabTitleBarLayout {
            Text("Needs attention")
            Spacer(minLength: 0)
            Text("\(items.count)").fontWeight(.regular)
        } content: {
            VStack(alignment: .leading, spacing: 6) {
                if items.isEmpty {
                    allClear
                } else {
                    ForEach(items.prefix(limit)) { AttentionRow(item: $0) }
                }
            }
        }
    }

    private var allClear: some View {
        VStack(spacing: 4) {
            Image(systemName: "checkmark.seal.fill").font(.title2).foregroundStyle(.green)
            Text("All clear").font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NeedsAttentionMediumView: View {
    let snapshot: LabSnapshot

    var body: some View {
        AttentionList(snapshot: snapshot, limit: 3)
    }
}

struct NeedsAttentionLargeView: View {
    let snapshot: LabSnapshot

    var body: some View {
        AttentionList(snapshot: snapshot, limit: 8)
    }
}

struct NeedsAttentionCircularView: View {
    let snapshot: LabSnapshot

    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: "tray.full.fill").font(.caption)
            Text("\(AttentionCollector.items(in: snapshot).count)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
        }
    }
}
