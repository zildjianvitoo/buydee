import Foundation

protocol GoalMessageGenerating: Sendable {
    func goalMessage(savedAmount: Int, goal: String) async throws -> String
}
