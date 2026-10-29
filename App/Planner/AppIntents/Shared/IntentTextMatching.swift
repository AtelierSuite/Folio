import Foundation

/// Matches what Siri heard ("dentist appointment") against item titles, word by word.
enum IntentTextMatching {
    static func words(in text: String) -> [String] {
        text.split { $0.isWhitespace || $0.isPunctuation }
            .map(String.init)
            .filter { !$0.isEmpty }
    }

    static func score(of words: [String], in fields: [String?]) -> Int {
        let texts = fields.compactMap { $0 }.filter { !$0.isEmpty }
        return words.filter { word in texts.contains { $0.localizedStandardContains(word) } }.count
    }
}
