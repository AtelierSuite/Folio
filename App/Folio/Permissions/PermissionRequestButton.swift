import Planner
import SwiftUI

struct PermissionRequestButton: View {
    @Environment(PermissionCenter.self) private var center
    let kind: PermissionKind
    var title: String?

    var body: some View {
        Button(title ?? kind.requestAction) {
            Task {
                await center.request(kind)
            }
        }
    }
}
