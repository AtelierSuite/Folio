import Planner
import SwiftUI

struct UndoToastView: View {
    let toast: UndoToast
    let onUndo: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Text(toast.action.toastTitle)
                .font(.subheadline.weight(.medium))
            Divider()
                .frame(height: 16)
            Button(String(localized: "Toast.Undo", table: "Undo"), action: onUndo)
                .font(.subheadline.weight(.semibold))
                .buttonStyle(.borderless)
                .accessibilityIdentifier("UndoToast.Undo")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .glassEffect(.regular.interactive(), in: .capsule)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("UndoToast")
    }
}
