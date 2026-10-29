import Foundation

public enum MarkdownTaskList {
    public static func togglingTask(atLine line: Int, in contents: String) -> String {
        var lines = contents.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let index = line - 1
        guard lines.indices.contains(index),
              let match = lines[index].firstMatch(of: taskMarker) else { return contents }
        let state = match.output.state
        lines[index].replaceSubrange(state.startIndex..<state.endIndex, with: state == " " ? "x" : " ")
        return lines.joined(separator: "\n")
    }

    private nonisolated(unsafe) static let taskMarker =
        #/^(?:[ \t]*>)*[ \t]*(?:[-+*]|\d{1,9}[.)])[ \t]+\[(?<state>[ xX])\]/#
}
