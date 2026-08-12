import Foundation

struct ChatServiceResponse: Equatable, Sendable {
    let content: String
    let updatedUserKnowledge: String?
    let decisionMetadata: DecisionMetadata?
    let selectedDecision: PurchaseDecision?

    init(rawContent: String) {
        var visibleContent = rawContent
        let knowledgePayload = Self.removeMarker(
            from: &visibleContent,
            opening: Self.knowledgeMarkerOpening
        )
        let decisionPayload = Self.removeMarker(
            from: &visibleContent,
            opening: Self.decisionMarkerOpening
        )
        let selectedDecisionPayload = Self.removeMarker(
            from: &visibleContent,
            opening: Self.selectedDecisionMarkerOpening
        )

        content = visibleContent.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedUserKnowledge = knowledgePayload.map { payload in
            let normalizedPayload = payload
                .split(whereSeparator: \Character.isWhitespace)
                .joined(separator: " ")
            return String(normalizedPayload.prefix(Self.maximumKnowledgeLength))
        }
        decisionMetadata = decisionPayload.flatMap(DecisionMetadata.init(markerPayload:))
        selectedDecision = selectedDecisionPayload.flatMap { payload in
            PurchaseDecision(rawValue: payload.lowercased())
        }
    }

    private static func removeMarker(from content: inout String, opening: String) -> String? {
        guard let openingRange = content.range(
            of: opening,
            options: [.caseInsensitive, .backwards]
        ) else {
            return nil
        }

        guard let closingRange = content.range(
            of: markerClosing,
            options: .caseInsensitive,
            range: openingRange.upperBound..<content.endIndex
        ) else {
            content.removeSubrange(openingRange.lowerBound..<content.endIndex)
            return nil
        }

        let payload = String(content[openingRange.upperBound..<closingRange.lowerBound])
            .trimmingCharacters(in: .whitespacesAndNewlines)
        content.removeSubrange(openingRange.lowerBound..<closingRange.upperBound)
        return payload
    }

    private static let knowledgeMarkerOpening = "<!-- BUYDEE_USER_KNOWLEDGE:"
    private static let decisionMarkerOpening = "<!-- BUYDEE_DECISION_METADATA:"
    private static let selectedDecisionMarkerOpening = "<!-- BUYDEE_SELECTED_DECISION:"
    private static let markerClosing = "-->"
    private static let maximumKnowledgeLength = 600
}
