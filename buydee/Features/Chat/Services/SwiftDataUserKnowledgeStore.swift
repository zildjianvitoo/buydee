import Foundation
import SwiftData

@MainActor
final class SwiftDataUserKnowledgeStore: UserKnowledgeStoring {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func currentKnowledge() throws -> String {
        let records = try fetchRecords()
        try removeDuplicateRecords(from: records)
        return records.first?.content ?? ""
    }

    func replaceKnowledge(with content: String) throws {
        let normalizedContent = String(
            content
                .split(whereSeparator: \Character.isWhitespace)
                .joined(separator: " ")
                .prefix(Self.maximumKnowledgeLength)
        )
        let records = try fetchRecords()

        if let record = records.first {
            record.content = normalizedContent
            record.updatedAt = .now
        } else {
            modelContext.insert(UserChatKnowledge(content: normalizedContent))
        }

        try removeDuplicateRecords(from: records)
        try modelContext.save()
    }

    private func fetchRecords() throws -> [UserChatKnowledge] {
        let descriptor = FetchDescriptor<UserChatKnowledge>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    private func removeDuplicateRecords(
        from records: [UserChatKnowledge]
    ) throws {
        guard records.count > 1 else { return }

        for duplicate in records.dropFirst() {
            modelContext.delete(duplicate)
        }
        try modelContext.save()
    }

    private static let maximumKnowledgeLength = 600
}
