import Foundation

nonisolated struct DecisionMetadata: Codable, Equatable, Sendable {
    let productName: String?
    let productCategory: String?
    let originalPriceText: String?
    let priceRangeLower: Int?
    let priceRangeUpper: Int?
    let contextSummary: String?
    let prosSummary: String?
    let consSummary: String?
    let relatedGoal: String?

    init(
        productName: String? = nil,
        productCategory: String? = nil,
        originalPriceText: String? = nil,
        priceRangeLower: Int? = nil,
        priceRangeUpper: Int? = nil,
        contextSummary: String? = nil,
        prosSummary: String? = nil,
        consSummary: String? = nil,
        relatedGoal: String? = nil
    ) {
        self.productName = productName
        self.productCategory = productCategory
        self.originalPriceText = originalPriceText
        self.priceRangeLower = priceRangeLower
        self.priceRangeUpper = priceRangeUpper
        self.contextSummary = contextSummary
        self.prosSummary = prosSummary
        self.consSummary = consSummary
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
            priceRangeLower: Self.validPrice(decoded.priceRangeLower),
            priceRangeUpper: Self.validPrice(decoded.priceRangeUpper),
            contextSummary: Self.normalized(decoded.contextSummary, maximumLength: 240),
            prosSummary: Self.normalized(decoded.prosSummary, maximumLength: 200),
            consSummary: Self.normalized(decoded.consSummary, maximumLength: 200),
            relatedGoal: Self.normalized(decoded.relatedGoal, maximumLength: 120)
        )
    }

    private enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case productCategory = "product_category"
        case originalPriceText = "original_price_text"
        case priceRangeLower = "price_range_lower"
        case priceRangeUpper = "price_range_upper"
        case contextSummary = "context_summary"
        case prosSummary = "pros_summary"
        case consSummary = "cons_summary"
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
