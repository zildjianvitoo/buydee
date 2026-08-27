import Foundation

protocol ChatServicing: Sendable {
    func response(
        to latestMessage: ChatMessage,
        history: [ChatMessage],
        goals: String,
        userKnowledge: String,
        decisionHistory: [PurchaseDecisionMemory],
        language: ChatLanguage
    ) async throws -> ChatServiceResponse
}
