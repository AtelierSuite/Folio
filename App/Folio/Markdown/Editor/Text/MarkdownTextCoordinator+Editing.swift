import Planner
import SwiftUI

extension MarkdownTextCoordinator {
    func apply(_ action: MarkdownFormattingAction) {
        guard let host else { return }
        let display = host.markdownStorage.string
        guard let selection = Range(host.markdownSelection, in: display) else { return }
        let lowerBound = display.distance(from: display.startIndex, to: selection.lowerBound)
        let upperBound = display.distance(from: display.startIndex, to: selection.upperBound)
        let edit = MarkdownTextEdit(text: display, selection: lowerBound..<upperBound).applying(action)
        let newLowerBound = edit.text.index(edit.text.startIndex, offsetBy: edit.selection.lowerBound)
        let newUpperBound = edit.text.index(edit.text.startIndex, offsetBy: edit.selection.upperBound)
        performEdit { storage in
            Self.replaceCharacters(of: storage, with: edit.text)
            return NSRange(newLowerBound..<newUpperBound, in: edit.text)
        }
    }

    func insertImage(markdown: String) {
        guard let host else { return }
        let selection = host.markdownSelection
        let string = host.markdownStorage.string as NSString
        let needsLeadingBreak = selection.location > 0 && string.character(at: selection.location - 1) != 10
        let selectionEnd = NSMaxRange(selection)
        let needsTrailingBreak = selectionEnd >= string.length || string.character(at: selectionEnd) != 10
        let snippet = (needsLeadingBreak ? "\n" : "") + markdown + (needsTrailingBreak ? "\n" : "")
        let insertion = attributedString(fromMarkdown: snippet)
        performEdit { storage in
            storage.replaceCharacters(in: selection, with: insertion)
            let caret = selection.location + insertion.length + (needsTrailingBreak ? 0 : 1)
            return NSRange(location: caret, length: 0)
        }
        host.focusMarkdownText()
    }

    func toggleTask(markerRange: NSRange) {
        guard let host else { return }
        let string = host.markdownStorage.string as NSString
        guard NSMaxRange(markerRange) <= string.length else { return }
        let box = (string.substring(with: markerRange) as NSString).range(of: "[")
        guard box.location != NSNotFound else { return }
        let stateRange = NSRange(location: markerRange.location + box.location + 1, length: 1)
        let isChecked = string.substring(with: stateRange) != " "
        let selection = host.markdownSelection
        performEdit { storage in
            storage.replaceCharacters(in: stateRange, with: isChecked ? " " : "x")
            return selection
        }
    }

    private func performEdit(_ edit: (NSTextStorage) -> NSRange) {
        guard let host else { return }
        host.prepareForProgrammaticEdit()
        let snapshot = NSAttributedString(attributedString: host.markdownStorage)
        let previousSelection = host.markdownSelection
        let selection = edit(host.markdownStorage)
        restyle()
        host.markdownSelection = Self.clamped(selection, to: host.markdownStorage.length)
        registerUndo(restoring: snapshot, selection: previousSelection)
        textDidChange()
    }

    private func registerUndo(restoring snapshot: NSAttributedString, selection: NSRange) {
        guard let host else { return }
        let current = NSAttributedString(attributedString: host.markdownStorage)
        let currentSelection = host.markdownSelection
        host.markdownUndoManager.registerUndo(withTarget: self) { coordinator in
            MainActor.assumeIsolated {
                coordinator.restore(snapshot, selection: selection)
                coordinator.registerUndo(restoring: current, selection: currentSelection)
            }
        }
    }

    private func restore(_ snapshot: NSAttributedString, selection: NSRange) {
        guard let host else { return }
        host.prepareForProgrammaticEdit()
        host.markdownStorage.setAttributedString(snapshot)
        restyle()
        host.markdownSelection = Self.clamped(selection, to: host.markdownStorage.length)
        textDidChange()
    }

    /// Replaces only what changed, carrying images over to the attachment characters still in the new text.
    private static func replaceCharacters(of storage: NSTextStorage, with newText: String) {
        let old = storage.string as NSString
        let new = newText as NSString
        var prefix = 0
        while prefix < old.length, prefix < new.length, old.character(at: prefix) == new.character(at: prefix) {
            prefix += 1
        }
        var suffix = 0
        while suffix < old.length - prefix, suffix < new.length - prefix,
              old.character(at: old.length - 1 - suffix) == new.character(at: new.length - 1 - suffix) {
            suffix += 1
        }
        let oldRange = NSRange(location: prefix, length: old.length - prefix - suffix)
        let newMiddle = new.substring(with: NSRange(location: prefix, length: new.length - prefix - suffix))
        var attachments = MarkdownAttributedText.attachments(in: storage, range: oldRange).map { $0.1 }[...]
        let replacement = NSMutableAttributedString(string: newMiddle)
        let middle = newMiddle as NSString
        for location in 0..<middle.length
        where MarkdownAttributedText.isAttachmentCharacter(middle.character(at: location)) {
            guard let attachment = attachments.popFirst() else { break }
            replacement.addAttribute(.attachment, value: attachment, range: NSRange(location: location, length: 1))
        }
        storage.replaceCharacters(in: oldRange, with: replacement)
    }
}
