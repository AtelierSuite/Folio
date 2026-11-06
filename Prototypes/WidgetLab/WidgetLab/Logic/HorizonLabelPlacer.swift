import Foundation

struct HorizonPlacement: Identifiable {
    var item: HorizonItem
    var dotX: CGFloat
    var lane: Int?
    var labelX: CGFloat
    var labelWidth: CGFloat
    var id: String { item.id }
}

/// Fits labels into a lane above and a lane below the line. An item with no room keeps its dot only.
enum HorizonLabelPlacer {
    static let characterWidth: CGFloat = 5.6
    static let widestLabel: CGFloat = 88
    static let labelGap: CGFloat = 6

    static func place(_ items: [HorizonItem], width: CGFloat) -> [HorizonPlacement] {
        var laneEnds: [CGFloat] = [-labelGap, -labelGap]
        return items.map { item in
            let dotX = width * HorizonScale.position(daysAway: Double(item.daysAway))
            let labelWidth = min(CGFloat(item.title.count) * characterWidth, widestLabel)
            let centered = min(max(dotX - labelWidth / 2, 0), width - labelWidth)
            for lane in laneEnds.indices {
                let labelX = max(centered, laneEnds[lane] + labelGap)
                if labelX <= dotX, labelX + labelWidth <= width {
                    laneEnds[lane] = labelX + labelWidth
                    return HorizonPlacement(item: item, dotX: dotX, lane: lane, labelX: labelX, labelWidth: labelWidth)
                }
            }
            return HorizonPlacement(item: item, dotX: dotX, lane: nil, labelX: 0, labelWidth: 0)
        }
    }
}
