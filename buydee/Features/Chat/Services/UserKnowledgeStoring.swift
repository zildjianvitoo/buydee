import Foundation

@MainActor
protocol UserKnowledgeStoring: AnyObject {
    func currentKnowledge() throws -> String
    func replaceKnowledge(with content: String) throws
}
