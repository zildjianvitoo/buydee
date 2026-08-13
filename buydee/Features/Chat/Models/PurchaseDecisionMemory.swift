import Foundation
import SwiftData

struct PurchaseDecisionMemory: Identifiable, Equatable, Sendable {
    let id: UUID
    let sessionID: UUID
    let productName: String
    let productCategory: String?
    let priceInRupiah: Int?
    let originalPriceText: String?
    let priceIsEstimated: Bool
    let priceRangeLower: Int?
    let priceRangeUpper: Int?
    let decision: PurchaseDecision
    let decidedAt: Date
    let contextSummary: String
    let relatedGoal: String?
}

@Model
final class PurchaseDecisionRecord {
    var id: UUID
    var sessionID: UUID
    var productName: String
    var productCategory: String?
    var priceInRupiah: Int?
    var originalPriceText: String?
    var priceIsEstimated: Bool
    var priceRangeLower: Int?
    var priceRangeUpper: Int?
    var decisionRawValue: String
    var decidedAt: Date
    var contextSummary: String
    // Kept only so existing SwiftData stores can migrate without losing records.
    // New prompt and UI contracts no longer create separate pros/cons content.
    var prosSummary: String
    var consSummary: String
    var relatedGoal: String?

    init(memory: PurchaseDecisionMemory) {
        id = memory.id
        sessionID = memory.sessionID
        productName = memory.productName
        productCategory = memory.productCategory
        priceInRupiah = memory.priceInRupiah
        originalPriceText = memory.originalPriceText
        priceIsEstimated = memory.priceIsEstimated
        priceRangeLower = memory.priceRangeLower
        priceRangeUpper = memory.priceRangeUpper
        decisionRawValue = memory.decision.rawValue
        decidedAt = memory.decidedAt
        contextSummary = memory.contextSummary
        prosSummary = ""
        consSummary = ""
        relatedGoal = memory.relatedGoal
    }

    var memory: PurchaseDecisionMemory? {
        guard let decision = PurchaseDecision(rawValue: decisionRawValue) else { return nil }
        return PurchaseDecisionMemory(
            id: id,
            sessionID: sessionID,
            productName: productName,
            productCategory: productCategory,
            priceInRupiah: priceInRupiah,
            originalPriceText: originalPriceText,
            priceIsEstimated: priceIsEstimated,
            priceRangeLower: priceRangeLower,
            priceRangeUpper: priceRangeUpper,
            decision: decision,
            decidedAt: decidedAt,
            contextSummary: contextSummary,
            relatedGoal: relatedGoal
        )
    }

    func replace(with memory: PurchaseDecisionMemory) {
        id = memory.id
        productName = memory.productName
        productCategory = memory.productCategory
        priceInRupiah = memory.priceInRupiah
        originalPriceText = memory.originalPriceText
        priceIsEstimated = memory.priceIsEstimated
        priceRangeLower = memory.priceRangeLower
        priceRangeUpper = memory.priceRangeUpper
        decisionRawValue = memory.decision.rawValue
        decidedAt = memory.decidedAt
        contextSummary = memory.contextSummary
        prosSummary = ""
        consSummary = ""
        relatedGoal = memory.relatedGoal
    }
}
