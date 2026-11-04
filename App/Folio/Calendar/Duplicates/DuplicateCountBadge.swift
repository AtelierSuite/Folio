import CoreText
import SwiftUI

struct DuplicateCountBadge: View {
    private static let numberScale = 0.65

    let count: Int

    @Environment(\.font) private var inheritedFont
    @Environment(\.fontResolutionContext) private var fontResolutionContext

    private var titleFont: Font {
        inheritedFont ?? .body
    }

    private var resolvedTitleFont: Font.Resolved {
        titleFont.resolve(in: fontResolutionContext)
    }

    static func accessibilityDescription(count: Int) -> String {
        String(localized: "Duplicates.Count \(count)", table: "Calendar")
    }

    var body: some View {
        if count > 1 {
            Text(count, format: .number)
                .font(titleFont.scaled(by: Self.numberScale).weight(.bold))
                .monospacedDigit()
                .lineLimit(1)
                .padding(.horizontal, resolvedTitleFont.pointSize * 0.2)
                .frame(minWidth: resolvedTitleFont.pointSize, minHeight: resolvedTitleFont.pointSize)
                .background(.secondary.opacity(0.25), in: .capsule)
                .fixedSize()
                .alignmentGuide(.firstTextBaseline) { dimensions in
                    dimensions[VerticalAlignment.center] + CTFontGetCapHeight(resolvedTitleFont.ctFont) / 2
                }
                .accessibilityLabel(Self.accessibilityDescription(count: count))
        }
    }
}
