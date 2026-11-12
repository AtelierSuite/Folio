import SwiftUI

struct OnboardingTimelineItemView: View {
    let item: OnboardingTimelineItem

    var body: some View {
        switch item.placement {
        case .block: block
        case .reminder: reminder
        case .gutter: symbol(item.symbol ?? "sun.max.fill").symbolRenderingMode(.multicolor)
        case .badge:
            symbol("bell.badge.fill")
                .foregroundStyle(item.color)
                .padding(.top, 5)
                .padding(.trailing, 8)
        }
    }

    private var block: some View {
        HStack(alignment: .top, spacing: 6) {
            Capsule()
                .fill(item.color)
                .frame(width: 3)
            if let symbol = item.symbol {
                Image(systemName: symbol)
                    .font(.footnote)
                    .foregroundStyle(item.color)
            }
            Capsule()
                .fill(item.color.opacity(0.5))
                .frame(width: 64, height: 6)
                .padding(.top, 3)
            Spacer(minLength: 0)
        }
        .padding(5)
        .background(item.color.opacity(0.18), in: .rect(cornerRadius: 6))
    }

    private var reminder: some View {
        HStack(spacing: 6) {
            Circle()
                .strokeBorder(item.color, lineWidth: 2)
                .frame(width: 14, height: 14)
            Capsule()
                .fill(item.color.opacity(0.5))
                .frame(width: 80, height: 6)
            Spacer(minLength: 0)
        }
    }

    private func symbol(_ name: String) -> some View {
        Image(systemName: name)
            .font(.subheadline)
    }
}
