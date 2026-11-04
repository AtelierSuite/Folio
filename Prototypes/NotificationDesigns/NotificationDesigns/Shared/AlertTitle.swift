import SwiftUI

struct AlertTitle: View {
    let alert: SampleAlert

    var body: some View {
        Text(alert.title)
            .font(.title3.bold())
            .lineLimit(3)
    }
}
