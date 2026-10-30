import SwiftUI

extension View {
    /// Presents the dialogs `anchored` adds to its anchor from `rect` in `space`, or from this whole
    /// view without one. A confirmation dialog's popover points at the view it's attached to, so a
    /// dialog on a whole screen would otherwise open from the middle of it.
    func dialogAnchor<Space: CoordinateSpaceProtocol, Anchored: View>(
        at rect: CGRect?,
        in space: Space,
        @ViewBuilder anchored: @escaping (DialogAnchor) -> Anchored
    ) -> some View {
        overlay {
            GeometryReader { proxy in
                let bounds = proxy.frame(in: space)
                let frame = rect.map { $0.offsetBy(dx: -bounds.minX, dy: -bounds.minY) }
                    ?? CGRect(origin: .zero, size: bounds.size)
                anchored(DialogAnchor(size: frame.size))
                    .position(x: frame.midX, y: frame.midY)
            }
            .allowsHitTesting(false)
        }
    }
}

struct DialogAnchor: View {
    let size: CGSize

    var body: some View {
        Color.clear
            .frame(width: max(size.width, 1), height: max(size.height, 1))
    }
}
