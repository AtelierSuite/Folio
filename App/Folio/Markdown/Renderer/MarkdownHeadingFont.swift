import SwiftUI

enum MarkdownHeadingFont {
    static func font(forLevel level: Int) -> Font {
        switch level {
        case 1: .largeTitle.bold()
        case 2: .title.bold()
        case 3: .title2.bold()
        case 4: .title3.bold()
        case 5: .headline
        default: .subheadline.bold()
        }
    }
}
