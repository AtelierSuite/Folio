import SwiftUI

struct OnboardingFolioPagesPalette {
    let colorScheme: ColorScheme

    private var isDark: Bool { colorScheme == .dark }

    var paper: Color {
        isDark ? Color(red: 0.17, green: 0.165, blue: 0.155) : Color(red: 0.995, green: 0.975, blue: 0.93)
    }

    var paperEdge: Color {
        isDark ? Color(red: 0.32, green: 0.3, blue: 0.28) : Color(red: 0.86, green: 0.83, blue: 0.76)
    }

    var ink: Color {
        isDark ? Color(red: 0.87, green: 0.88, blue: 0.93) : Color(red: 0.16, green: 0.2, blue: 0.34)
    }

    var rule: Color {
        Color(red: 0.42, green: 0.58, blue: 0.85).opacity(isDark ? 0.2 : 0.26)
    }

    var margin: Color {
        Color.red.opacity(isDark ? 0.28 : 0.3)
    }

    var leather: Color { .accentColor }

    var leatherShade: Color { Color.accentColor.mix(with: .black, by: isDark ? 0.55 : 0.4) }
}
