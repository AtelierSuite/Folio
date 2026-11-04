import SwiftUI

struct WallpaperView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }

    private var colors: [Color] {
        colorScheme == .dark
            ? [Color(red: 0.08, green: 0.1, blue: 0.2), Color(red: 0.2, green: 0.1, blue: 0.24)]
            : [Color(red: 0.72, green: 0.82, blue: 0.95), Color(red: 0.95, green: 0.8, blue: 0.82)]
    }
}
