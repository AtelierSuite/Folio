import SwiftUI

struct WidgetCard<Content: View>: View {
    let family: LabFamily
    @ViewBuilder let content: Content

    var body: some View {
        if family.isAccessory {
            accessory
        } else {
            content
                .frame(width: family.size.width, height: family.size.height)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 24, style: .continuous))
                .shadow(color: .black.opacity(0.08), radius: 6, y: 2)
        }
    }

    private var accessory: some View {
        content
            .frame(width: family.size.width, height: family.size.height)
            .foregroundStyle(.white)
            .padding(10)
            .background(Color(red: 0.13, green: 0.15, blue: 0.24), in: .rect(cornerRadius: 16, style: .continuous))
            .environment(\.colorScheme, .dark)
    }
}
