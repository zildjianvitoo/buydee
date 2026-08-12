import Foundation

enum RupiahCurrency {
    static func firstAmount(in text: String) -> Int? {
        let pattern = #"(?i)\bRp\s*([0-9]+(?:[.,][0-9]+)*)\s*(juta|jt|ribu|rb|k)?"#
        guard let expression = try? NSRegularExpression(pattern: pattern),
              let match = expression.firstMatch(
                in: text,
                range: NSRange(text.startIndex..., in: text)
              ),
              let numberRange = Range(match.range(at: 1), in: text) else {
            return nil
        }

        let numberText = String(text[numberRange])
        let unit: String
        if let unitRange = Range(match.range(at: 2), in: text) {
            unit = String(text[unitRange]).lowercased()
        } else {
            unit = ""
        }

        let amount: Double
        if unit.isEmpty {
            let digits = numberText.filter(\.isNumber)
            guard let parsedAmount = Double(digits) else { return nil }
            amount = parsedAmount
        } else {
            let normalizedNumber = normalizedDecimal(numberText)
            guard let parsedAmount = Double(normalizedNumber) else { return nil }
            let multiplier = unit == "juta" || unit == "jt" ? 1_000_000.0 : 1_000.0
            amount = parsedAmount * multiplier
        }

        guard amount > 0, amount <= Double(Int.max) else { return nil }
        return Int(amount.rounded())
    }

    static func formatted(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let number = formatter.string(from: NSNumber(value: max(0, amount))) ?? String(max(0, amount))
        return "Rp \(number)"
    }

    private static func normalizedDecimal(_ value: String) -> String {
        guard let separatorIndex = value.lastIndex(where: { $0 == "." || $0 == "," }) else {
            return value
        }

        let fractionLength = value.distance(from: value.index(after: separatorIndex), to: value.endIndex)
        if fractionLength <= 2 {
            let integerPart = value[..<separatorIndex].filter(\.isNumber)
            let fractionPart = value[value.index(after: separatorIndex)...].filter(\.isNumber)
            return "\(integerPart).\(fractionPart)"
        }

        return String(value.filter(\.isNumber))
    }
}
