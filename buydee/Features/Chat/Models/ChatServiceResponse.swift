import Foundation

struct ChatServiceResponse: Equatable, Sendable {
    let content: String
    let updatedUserKnowledge: String?

    init(rawContent: String) {
        guard let openingRange = rawContent.range(
            of: Self.knowledgeMarkerOpening,
            options: [.caseInsensitive, .backwards]
        ) else {
            content = rawContent.trimmingCharacters(in: .whitespacesAndNewlines)
            updatedUserKnowledge = nil
            return
        }

        guard let closingRange = rawContent.range(
            of: Self.knowledgeMarkerClosing,
            options: .caseInsensitive,
            range: openingRange.upperBound..<rawContent.endIndex
        ) else {
            content = String(rawContent[..<openingRange.lowerBound])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            updatedUserKnowledge = nil
            return
        }

        let knowledge = rawContent[openingRange.upperBound..<closingRange.lowerBound]
            .split(whereSeparator: \Character.isWhitespace)
            .joined(separator: " ")
        let visiblePrefix = rawContent[..<openingRange.lowerBound]
        let visibleSuffix = rawContent[closingRange.upperBound...]

        content = "\(visiblePrefix)\(visibleSuffix)"
            .trimmingCharacters(in: .whitespacesAndNewlines)
        updatedUserKnowledge = String(knowledge.prefix(Self.maximumKnowledgeLength))
    }

    private static let knowledgeMarkerOpening = "<!-- BUYDEE_USER_KNOWLEDGE:"
    private static let knowledgeMarkerClosing = "-->"
    private static let maximumKnowledgeLength = 600
}
