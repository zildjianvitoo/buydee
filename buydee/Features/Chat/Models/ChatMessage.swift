import Foundation

struct ChatMessage: Identifiable, Equatable, Sendable {
    let id: UUID
    let role: ChatRole
    let content: String
    let imageData: Data?
    let decisionMetadata: DecisionMetadata?

    init(
        id: UUID = UUID(),
        role: ChatRole,
        content: String,
        imageData: Data? = nil,
        decisionMetadata: DecisionMetadata? = nil
    ) {
        self.id = id
        self.role = role
        self.content = content
        self.imageData = imageData
        self.decisionMetadata = decisionMetadata
    }

    var containsDecisionSummary: Bool {
        let normalizedContent = content.lowercased()
        return normalizedContent.contains("**pros:**")
            && normalizedContent.contains("**cons:**")
            && normalizedContent.contains("**buy**")
            && normalizedContent.contains("**bye**")
    }

    var decisionSummary: DecisionSummary? {
        guard role == .assistant, containsDecisionSummary else { return nil }
        return DecisionSummary(markdown: content, metadata: decisionMetadata)
    }
}
