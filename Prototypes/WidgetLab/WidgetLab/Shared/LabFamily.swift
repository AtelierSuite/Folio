import SwiftUI

enum LabFamily: String {
    case small = "Small"
    case medium = "Medium"
    case large = "Large"
    case circular = "Circular"
    case rectangular = "Rectangular"
    case inline = "Inline"

    var size: CGSize {
        switch self {
        case .small: CGSize(width: 158, height: 158)
        case .medium: CGSize(width: 338, height: 158)
        case .large: CGSize(width: 338, height: 354)
        case .circular: CGSize(width: 72, height: 72)
        case .rectangular: CGSize(width: 160, height: 72)
        case .inline: CGSize(width: 234, height: 22)
        }
    }

    var isAccessory: Bool {
        [.circular, .rectangular, .inline].contains(self)
    }
}
