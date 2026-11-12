import SwiftUI

struct OnboardingTimelineItemView: View {
    let item: OnboardingTimelineItem

    var body: some View {
        switch item.placement {
        case .block: block
        case .reminder: reminder
        case .gutter: symbol(item.symbol ?? "sun.max.fill").symbolRenderingMode(.multicolor)
        case .notification: notification
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

    private var notification: some View {
        HStack(spacing: 10) {
            Image(systemName: item.symbol ?? "bell.fill")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(item.color.gradient, in: .rect(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 6) {
                Capsule()
                    .fill(.primary.opacity(0.55))
                    .frame(width: 96, height: 6)
                Capsule()
                    .fill(.primary.opacity(0.2))
                    .frame(width: 150, height: 6)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .frame(maxHeight: .infinity)
        .background(.background, in: .rect(cornerRadius: 14))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 1)
    }

    private func symbol(_ name: String) -> some View {
        Image(systemName: name)
            .font(.subheadline)
    }
}
