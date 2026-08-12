import Foundation

protocol ChatServicing: Sendable {
    func response(
        to latestMessage: ChatMessage,
        history: [ChatMessage],
        goals: String
    ) async throws -> String
}
