import Foundation

nonisolated struct DecisionMetadata: Codable, Equatable, Sendable {
    let productName: String?
    let productCategory: String?
    let originalPriceText: String?
    let priceInRupiah: Int?
    let priceRangeLower: Int?
    let priceRangeUpper: Int?
    let contextSummary: String?
    let relatedGoal: String?

    init(
        productName: String? = nil,
        productCategory: String? = nil,
        originalPriceText: String? = nil,
        priceInRupiah: Int? = nil,
        priceRangeLower: Int? = nil,
        priceRangeUpper: Int? = nil,
        contextSummary: String? = nil,
        relatedGoal: String? = nil
    ) {
        self.productName = productName
        self.productCategory = productCategory
        self.originalPriceText = originalPriceText
        self.priceInRupiah = priceInRupiah
        self.priceRangeLower = priceRangeLower
        self.priceRangeUpper = priceRangeUpper
        self.contextSummary = contextSummary
        self.relatedGoal = relatedGoal
    }

    init?(markerPayload: String) {
        guard let data = markerPayload.data(using: .utf8),
              let decoded = try? JSONDecoder().decode(Self.self, from: data) else {
            return nil
        }

        self.init(
            productName: Self.normalized(decoded.productName, maximumLength: 100),
            productCategory: Self.normalized(decoded.productCategory, maximumLength: 80),
            originalPriceText: Self.normalized(decoded.originalPriceText, maximumLength: 100),
            priceInRupiah: Self.validPrice(decoded.priceInRupiah),
            priceRangeLower: Self.validPrice(decoded.priceRangeLower),
            priceRangeUpper: Self.validPrice(decoded.priceRangeUpper),
            contextSummary: Self.normalized(decoded.contextSummary, maximumLength: 240),
            relatedGoal: Self.normalized(decoded.relatedGoal, maximumLength: 120)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case productCategory = "product_category"
        case originalPriceText = "original_price_text"
        case priceInRupiah = "price_in_rupiah"
        case priceRangeLower = "price_range_lower"
        case priceRangeUpper = "price_range_upper"
        case contextSummary = "context_summary"
        case relatedGoal = "related_goal"
    }

    private static func normalized(
        _ value: String?,
        maximumLength: Int
    ) -> String? {
        guard let value else { return nil }
        let normalizedValue = value
            .split(whereSeparator: \Character.isWhitespace)
            .joined(separator: " ")
        guard !normalizedValue.isEmpty else { return nil }
        return String(normalizedValue.prefix(maximumLength))
    }

    private static func validPrice(_ value: Int?) -> Int? {
        guard let value, value > 0 else { return nil }
        return value
    }
}
