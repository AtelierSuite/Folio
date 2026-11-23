#if os(iOS)
import UIKit

/// Inline widgets only allow one line of text, but they keep template images, so the event's two lines
/// and the temperature beside them are drawn into one image, which the Lock Screen centres on the date.
enum WeatherUpNextInlineImage {
    static let maximumEventWidth: CGFloat = 140
    private static let spacing: CGFloat = 5
    /// Without it the image centres a little above the date's text.
    private static let topPadding: CGFloat = 5.5

    static func make(weatherSymbol: String, temperature: String, top: String, bottom: String) -> UIImage {
        let temperatureFont = UIFont.systemFont(ofSize: 22, weight: .medium)
        let eventFont = UIFontMetrics(forTextStyle: .caption1)
            .scaledFont(for: .systemFont(ofSize: 11, weight: .semibold), maximumPointSize: 13)
        let temperatureAttributes: [NSAttributedString.Key: Any] = [
            .font: temperatureFont,
            .foregroundColor: UIColor.white
        ]
        let temperatureSize = (temperature as NSString).size(withAttributes: temperatureAttributes)
        let weatherImage = symbol(named: "\(weatherSymbol).fill") ?? symbol(named: weatherSymbol)
        let calendarImage = symbol(named: "calendar")
        let eventLineHeight = ceil(eventFont.lineHeight)
        let widestLine = [top, bottom]
            .map { ($0 as NSString).size(withAttributes: eventAttributes(eventFont)).width }
            .max()
        let eventWidth = min(ceil(widestLine ?? 0), maximumEventWidth)
        let contentHeight = max(eventLineHeight * 2, temperatureSize.height)
        let padding = topPadding
        let height = contentHeight + padding
        let width = (weatherImage?.size.width ?? 0) + spacing + ceil(temperatureSize.width) + spacing
            + (calendarImage?.size.width ?? 0) + spacing + eventWidth
        let image = UIGraphicsImageRenderer(size: CGSize(width: width, height: height)).image { _ in
            var xPosition: CGFloat = 0
            func centredY(_ itemHeight: CGFloat) -> CGFloat { padding + (contentHeight - itemHeight) / 2 }
            if let weatherImage {
                weatherImage.draw(at: CGPoint(x: xPosition, y: centredY(weatherImage.size.height)))
                xPosition += weatherImage.size.width + spacing
            }
            (temperature as NSString).draw(
                at: CGPoint(x: xPosition, y: centredY(temperatureSize.height)),
                withAttributes: temperatureAttributes
            )
            xPosition += ceil(temperatureSize.width) + spacing
            if let calendarImage {
                calendarImage.draw(at: CGPoint(x: xPosition, y: centredY(calendarImage.size.height)))
                xPosition += calendarImage.size.width + spacing
            }
            let eventOrigin = CGPoint(x: xPosition, y: centredY(eventLineHeight * 2))
            let eventFrame = CGRect(origin: eventOrigin, size: CGSize(width: eventWidth, height: eventLineHeight * 2))
            drawEvent([top, bottom], font: eventFont, in: eventFrame)
        }
        return image.withRenderingMode(.alwaysTemplate)
    }

    private static func symbol(named name: String) -> UIImage? {
        UIImage(
            systemName: name,
            withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 17, weight: .medium))
        )?.withTintColor(.white, renderingMode: .alwaysOriginal)
    }

    private static func eventAttributes(_ font: UIFont) -> [NSAttributedString.Key: Any] {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byTruncatingTail
        return [.font: font, .foregroundColor: UIColor.white, .paragraphStyle: paragraph]
    }

    private static func drawEvent(_ lines: [String], font: UIFont, in frame: CGRect) {
        let lineHeight = ceil(font.lineHeight)
        for (index, line) in lines.enumerated() {
            let lineOrigin = CGPoint(x: frame.minX, y: frame.minY + lineHeight * CGFloat(index))
            let lineRect = CGRect(origin: lineOrigin, size: CGSize(width: frame.width, height: lineHeight))
            (line as NSString).draw(in: lineRect, withAttributes: eventAttributes(font))
        }
    }
}
#endif
