import Foundation

@MainActor
protocol DecisionHistoryStoring: AnyObject {
    func recentDecisions(limit: Int) throws -> [PurchaseDecisionMemory]
    func save(_ memory: PurchaseDecisionMemory) throws
}
