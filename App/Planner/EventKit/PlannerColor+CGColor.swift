import CoreGraphics

extension PlannerColor {
    init(_ cgColor: CGColor?) {
        guard let cgColor,
              let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
              let converted = cgColor.converted(to: colorSpace, intent: .defaultIntent, options: nil),
              let components = converted.components,
              components.count >= 3 else {
            self = .gray
            return
        }
        self.init(
            red: Double(components[0]),
            green: Double(components[1]),
            blue: Double(components[2]),
            alpha: Double(converted.alpha)
        )
    }
}
