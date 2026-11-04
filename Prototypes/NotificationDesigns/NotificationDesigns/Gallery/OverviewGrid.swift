import SwiftUI

struct OverviewGrid: View {
    let alert: SampleAlert
    let onSelect: (NotificationDesign) -> Void

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 8, alignment: .top), GridItem(.flexible(), alignment: .top)],
                spacing: 8
            ) {
                ForEach(NotificationDesign.allCases) { design in
                    OverviewCell(design: design, alert: alert)
                        .onTapGesture { onSelect(design) }
                }
            }
            .padding(.horizontal, 8)
        }
    }
}

private struct OverviewCell: View {
    let design: NotificationDesign
    let alert: SampleAlert

    private let scale: CGFloat = 0.5
    private let fullWidth: CGFloat = 378
    @State private var fullHeight: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(design.name)
                .font(.caption2.weight(.semibold))
                .padding(.leading, 4)
            MockNotificationView(design: design, alert: alert, showsActions: false)
                .frame(width: fullWidth)
                .fixedSize(horizontal: false, vertical: true)
                .onGeometryChange(for: CGFloat.self, of: \.size.height) { fullHeight = $0 }
                .scaleEffect(scale, anchor: .topLeading)
                .frame(width: fullWidth * scale, height: fullHeight * scale, alignment: .topLeading)
        }
    }
}
