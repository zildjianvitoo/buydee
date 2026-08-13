import Foundation

struct ChatMessage: Identifiable, Equatable, Sendable {
    let id: UUID
    let role: ChatRole
    let content: String
    let imageData: Data?
    let decisionMetadata: DecisionMetadata?
    let selectedDecision: PurchaseDecision?

    init(
        id: UUID = UUID(),
        role: ChatRole,
        content: String,
        imageData: Data? = nil,
        decisionMetadata: DecisionMetadata? = nil,
        selectedDecision: PurchaseDecision? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.imageData = imageData
        self.decisionMetadata = decisionMetadata
        self.selectedDecision = selectedDecision
    }

    var containsDecisionSummary: Bool {
        guard decisionMetadata != nil, selectedDecision == nil else { return false }
        let normalizedContent = content.lowercased()
        return normalizedContent.contains("**buy**")
            && normalizedContent.contains("**bye**")
    }

    var decisionSummary: DecisionSummary? {
        guard role == .assistant, containsDecisionSummary else { return nil }
        return DecisionSummary(markdown: content, metadata: decisionMetadata)
    }

    nonisolated var bubbleContent: String {
        guard role == .assistant else { return content }

        let lines = content
            .replacingOccurrences(of: "\r\n", with: "\n")
            .components(separatedBy: "\n")
        let nonHeadingLines = lines.filter { !Self.isMarkdownHeading($0) }
        let withoutHeadings = nonHeadingLines
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let cleanedContent: String
        if !withoutHeadings.isEmpty {
            cleanedContent = withoutHeadings
        } else {
            cleanedContent = lines
                .map(Self.removingMarkdownHeadingMarker)
                .joined(separator: "\n")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return Self.separatingFinalQuestion(
            in: RupiahCurrency.expandingShorthand(in: cleanedContent)
        )
    }

    nonisolated private static func isMarkdownHeading(_ line: String) -> Bool {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        let markerCount = trimmed.prefix { $0 == "#" }.count
        guard (1...6).contains(markerCount), markerCount < trimmed.count else {
            return false
        }
        let contentIndex = trimmed.index(trimmed.startIndex, offsetBy: markerCount)
        return trimmed[contentIndex].isWhitespace
    }

    nonisolated private static func removingMarkdownHeadingMarker(_ line: String) -> String {
        guard isMarkdownHeading(line) else { return line }
        return String(line.drop { $0 == "#" || $0.isWhitespace })
            .trimmingCharacters(in: .whitespaces)
    }

    nonisolated private static func separatingFinalQuestion(in content: String) -> String {
        guard let questionMark = content.lastIndex(of: "?") else { return content }

        let beforeQuestionMark = content[..<questionMark]
        if let lastNewline = beforeQuestionMark.lastIndex(of: "\n") {
            let questionStart = content.index(after: lastNewline)
            return joiningWithParagraphBreak(
                explanation: content[..<lastNewline],
                question: content[questionStart...]
            ) ?? content
        }

        if let sentenceEnd = beforeQuestionMark.lastIndex(where: { character in
            character == "." || character == "!" || character == "?"
        }) {
            let questionStart = content.index(after: sentenceEnd)
            return joiningWithParagraphBreak(
                explanation: content[...sentenceEnd],
                question: content[questionStart...]
            ) ?? content
        }

        let questionOpeners = [
            " kalau ", " apa ", " bagaimana ", " gimana ", " seberapa ",
            " kapan ", " menurut kamu ", " kamu kebayang ",
            " kamu membayangkan ", " what ", " how ", " when ", " which ",
            " where ", " do you ", " would you ", " could you ",
            " can you ", " are you ", " have you ", " if ",
        ]
        let openerRanges = questionOpeners.compactMap { opener in
            content.range(
                of: opener,
                options: [.caseInsensitive],
                range: content.startIndex..<questionMark
            )
        }
        guard let questionRange = openerRanges.min(by: {
            $0.lowerBound < $1.lowerBound
        }) else {
            return content
        }
        let questionStart = content.index(after: questionRange.lowerBound)
        return joiningWithParagraphBreak(
            explanation: content[..<questionRange.lowerBound],
            question: content[questionStart...]
        ) ?? content
    }

    nonisolated private static func joiningWithParagraphBreak(
        explanation: Substring,
        question: Substring
    ) -> String? {
        let cleanExplanation = explanation
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanQuestion = question
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanExplanation.isEmpty, !cleanQuestion.isEmpty else { return nil }
        return "\(cleanExplanation)\n\n\(cleanQuestion)"
    }
}
