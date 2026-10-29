import SwiftUI

struct MarkdownTaskToggleAction {
    let perform: (Int) -> Void

    init(_ perform: @escaping (Int) -> Void) {
        self.perform = perform
    }

    func callAsFunction(line: Int) {
        perform(line)
    }
}

extension EnvironmentValues {
    @Entry var markdownBaseURL: URL?
    @Entry var markdownTaskToggleAction: MarkdownTaskToggleAction?
}
