import Foundation

enum PurchaseDecision: String, Identifiable, Hashable, Sendable {
    case buy
    case bye

    var id: Self { self }

    func apiMessage(in language: ChatLanguage) -> String {
        switch (self, language) {
        case (.buy, .indonesian):
            "BUY, beli sekarang"
        case (.bye, .indonesian):
            "BYE, tidak beli sekarang"
        case (.buy, .english):
            "BUY, buy now"
        case (.bye, .english):
            "BYE, do not buy now"
        }
    }
}
