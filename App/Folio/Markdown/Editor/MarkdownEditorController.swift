import Observation
import Planner

@Observable
final class MarkdownEditorController {
    var isEditing = false
    @ObservationIgnored weak var coordinator: MarkdownTextCoordinator?

    func apply(_ action: MarkdownFormattingAction) {
        coordinator?.apply(action)
    }

    func insertImage(markdown: String) {
        coordinator?.insertImage(markdown: markdown)
    }
}
