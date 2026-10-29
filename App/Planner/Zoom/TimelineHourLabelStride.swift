import CoreGraphics

/// Thins the hour labels out when the hours get shorter than a label.
public enum TimelineHourLabelStride {
    public static let candidates = [1, 2, 3, 4, 6, 12]

    public static func stride(hourHeight: CGFloat, labelHeight: CGFloat, spacing: CGFloat = 1.15) -> Int {
        let needed = labelHeight * spacing
        return candidates.first { CGFloat($0) * hourHeight >= needed } ?? 24
    }
}
