import SwiftUI

struct TimelineLayersView: View {
    let layers: [TimelineLayer]
    let context: TimelineLayerContext

    var body: some View {
        ForEach(layers) { layer in
            layer.content(in: context)
        }
    }
}
