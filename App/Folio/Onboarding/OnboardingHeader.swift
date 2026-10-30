import SwiftUI

struct OnboardingHeader: View {
    private static let appName = "Folio"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.black)
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("OnboardingTitle")
            Text(String(localized: "Welcome.Subtitle", table: "Onboarding"))
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.leading)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var title: AttributedString {
        var title = AttributedString(String(localized: "Welcome.Title", table: "Onboarding"))
        if let range = title.range(of: Self.appName) {
            title[range].foregroundColor = .accentColor
        }
        return title
    }
}
