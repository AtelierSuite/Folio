import SwiftUI

enum HarnessAppearance: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }
    var colorScheme: ColorScheme { self == .light ? .light : .dark }
}

enum HarnessTextSize: String, CaseIterable, Identifiable {
    case standard = "Standard"
    case large = "Accessibility"

    var id: String { rawValue }
    var dynamicTypeSize: DynamicTypeSize { self == .standard ? .large : .accessibility2 }
}

enum HarnessLayout: String, CaseIterable, Identifiable {
    case overview = "Grid"
    case compare = "List"
    case focus = "One"

    var id: String { rawValue }
}
