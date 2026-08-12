import Foundation

enum PurchaseDecision: String, Identifiable, Hashable, Sendable {
    case buy
    case bye

    var id: Self { self }

    var apiMessage: String {
        switch self {
        case .buy:
            "BUY — Beli sekarang"
        case .bye:
            "BYE — Tidak beli sekarang"
        }
    }
}
