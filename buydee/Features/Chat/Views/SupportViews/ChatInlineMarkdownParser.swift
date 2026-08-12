import SwiftUI

enum ChatInlineMarkdownParser {
    private static let highlightStart = "\u{E000}"
    private static let highlightEnd = "\u{E001}"
    private static let highlightStartCharacter: Character = "\u{E000}"
    private static let highlightEndCharacter: Character = "\u{E001}"

    static func parse(_ source: String) -> AttributedString {
        let sourceWithHighlightMarkers = encodeCompleteHighlights(in: source)

        guard var attributedString = try? AttributedString(
            markdown: sourceWithHighlightMarkers,
            options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        ) else {
            return AttributedString(source)
        }

        styleInlineCode(in: &attributedString)
        applyHighlights(in: &attributedString)
        return attributedString
    }

    private static func encodeCompleteHighlights(in source: String) -> String {
        var result = ""
        var currentIndex = source.startIndex

        while let openingRange = source.range(
            of: "==",
            range: currentIndex..<source.endIndex
        ) {
            result.append(contentsOf: source[currentIndex..<openingRange.lowerBound])

            guard let closingRange = source.range(
                of: "==",
                range: openingRange.upperBound..<source.endIndex
            ) else {
                result.append(contentsOf: source[openingRange.lowerBound...])
                return result
            }

            result.append(highlightStart)
            result.append(contentsOf: source[openingRange.upperBound..<closingRange.lowerBound])
            result.append(highlightEnd)
            currentIndex = closingRange.upperBound
        }

        result.append(contentsOf: source[currentIndex...])
        return result
    }

    private static func styleInlineCode(in attributedString: inout AttributedString) {
        let codeRanges = attributedString.runs.compactMap { run in
            run.inlinePresentationIntent?.contains(.code) == true ? run.range : nil
        }

        for range in codeRanges {
            attributedString[range].font = .buydeeMarkdownInlineCode
            attributedString[range].backgroundColor = Color.buydee.chatCodeBackground
        }
    }

    private static func applyHighlights(in attributedString: inout AttributedString) {
        while let openingIndex = attributedString.characters.firstIndex(
            of: highlightStartCharacter
        ) {
            let highlightedContentStart = attributedString.characters.index(after: openingIndex)
            guard let closingIndex = attributedString.characters[
                highlightedContentStart...
            ].firstIndex(of: highlightEndCharacter) else {
                break
            }

            if highlightedContentStart < closingIndex {
                attributedString[highlightedContentStart..<closingIndex].backgroundColor =
                    Color.buydee.background
            }

            let afterClosingIndex = attributedString.characters.index(after: closingIndex)
            attributedString.removeSubrange(closingIndex..<afterClosingIndex)
            attributedString.removeSubrange(openingIndex..<highlightedContentStart)
        }
    }
}
