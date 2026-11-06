import SwiftUI

struct LabWidgetSpec: Identifiable {
    let family: LabFamily
    let render: (LabSnapshot) -> AnyView
    var id: String { family.rawValue }

    init<Content: View>(_ family: LabFamily, _ content: @escaping (LabSnapshot) -> Content) {
        self.family = family
        render = { AnyView(content($0)) }
    }
}

struct LabIdea: Identifiable {
    let number: Int
    let name: String
    let summary: String
    let dataNeeded: String
    let widgets: [LabWidgetSpec]
    var id: Int { number }
}
