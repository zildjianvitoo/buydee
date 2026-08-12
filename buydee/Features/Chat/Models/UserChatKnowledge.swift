import Foundation
import SwiftData

@Model
final class UserChatKnowledge {
    var content: String
    var updatedAt: Date

    init(content: String = "", updatedAt: Date = .now) {
        self.content = content
        self.updatedAt = updatedAt
    }
}
