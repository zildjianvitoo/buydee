import Foundation
import SwiftData

@MainActor
final class SwiftDataDecisionHistoryStore: DecisionHistoryStoring {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func recentDecisions(limit: Int) throws -> [PurchaseDecisionMemory] {
        guard limit > 0 else { return [] }

        var descriptor = FetchDescriptor<PurchaseDecisionRecord>(
            sortBy: [SortDescriptor(\.decidedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor).compactMap(\.memory)
    }

    func save(_ memory: PurchaseDecisionMemory) throws {
        let records = try allRecords()
        let matchingRecords = records.filter { $0.sessionID == memory.sessionID }

        if let existingRecord = matchingRecords.first {
            existingRecord.replace(with: memory)
            for duplicate in matchingRecords.dropFirst() {
                modelContext.delete(duplicate)
            }
        } else {
            modelContext.insert(PurchaseDecisionRecord(memory: memory))
        }

        try modelContext.save()
        try pruneRecordsIfNeeded()
    }

    private func allRecords() throws -> [PurchaseDecisionRecord] {
        let descriptor = FetchDescriptor<PurchaseDecisionRecord>(
            sortBy: [SortDescriptor(\.decidedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    private func pruneRecordsIfNeeded() throws {
        let records = try allRecords()
        guard records.count > Self.maximumRecordCount else { return }

        for record in records.dropFirst(Self.maximumRecordCount) {
            modelContext.delete(record)
        }
        try modelContext.save()
    }

    private static let maximumRecordCount = 30
}
