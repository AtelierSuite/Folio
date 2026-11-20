import SwiftUI

struct OnboardingLiquidGlassPiece: Identifiable {
    let id: Int
    let frame: CGRect
    var cornerRadius: CGFloat
    let tint: Color
    let content: OnboardingLiquidGlassPieceContent

    init(
        id: Int,
        frame: CGRect,
        cornerRadius: CGFloat? = nil,
        tint: Color,
        content: OnboardingLiquidGlassPieceContent
    ) {
        self.id = id
        self.frame = frame
        self.cornerRadius = cornerRadius ?? min(frame.width, frame.height) / 2
        self.tint = tint
        self.content = content
    }
}

enum OnboardingLiquidGlassPieceContent: Hashable {
    case symbol(String, [Color])
    case dot(Color)
    case event(Color)
    case reminder(Color, isDone: Bool)
    case island
    case banner
    case weather(String)
    case sleep(isGrown: Bool)

    var kind: String {
        switch self {
        case .symbol(let name, _): "symbol-\(name)"
        case .dot: "dot"
        case .event: "event"
        case .reminder: "reminder"
        case .island: "island"
        case .banner: "banner"
        case .weather(let name): "weather-\(name)"
        case .sleep: "sleep"
        }
    }
}

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
    }
}
