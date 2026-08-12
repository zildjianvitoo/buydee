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
}
