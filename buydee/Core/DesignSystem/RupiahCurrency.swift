import Foundation

nonisolated enum RupiahCurrency {
    static func firstAmount(in text: String) -> RupiahAmount? {
        if let rangeAmount = firstRangeMidpoint(in: text) {
            return rangeAmount
        }
        guard !containsOpenEndedRange(in: text) else { return nil }

        let currencyPattern = #"(?i)\b(?:Rp|IDR)\s*([0-9]+(?:[.,][0-9]+)*)\s*(juta|jt|ribu|rb|k)?"#
        if let amount = firstAmount(in: text, matching: currencyPattern) {
            return RupiahAmount(value: amount, isEstimated: false)
        }

        let shorthandPattern = #"(?i)\b([0-9]+(?:[.,][0-9]+)*)\s*(juta|jt|ribu|rb|k)\b"#
        guard let amount = firstAmount(in: text, matching: shorthandPattern) else {
            let contextualPattern = #"(?i)\b(?:harga(?:nya)?|price|seharga)\s*(?:adalah|is|:)?\s*([0-9]+(?:[.,][0-9]+)*)\s*(juta|jt|ribu|rb|k)?\b"#
            if let contextualAmount = firstAmount(in: text, matching: contextualPattern) {
                return RupiahAmount(value: contextualAmount, isEstimated: false)
            }

            let groupedNumberPattern = #"\b([0-9]{1,3}(?:\.[0-9]{3})+)\b"#
            guard let groupedAmount = firstAmount(
                in: text,
                matching: groupedNumberPattern,
                unitCaptureIndex: nil
            ) else {
                return nil
            }
            return RupiahAmount(value: groupedAmount, isEstimated: false)
        }
        return RupiahAmount(value: amount, isEstimated: false)
    }

    static func expandingShorthand(in text: String) -> String {
        let pattern = #"(?i)(?:\bRp\s*)?\b([0-9]+(?:[.,][0-9]+)*)\s*(juta|jt|ribu|rb|k)\b"#
        guard let expression = try? NSRegularExpression(pattern: pattern),
              !text.isEmpty else {
            return text
        }

        var result = text
        let matches = expression.matches(
            in: text,
            range: NSRange(text.startIndex..., in: text)
        )
        for match in matches.reversed() {
            guard let fullRange = Range(match.range(at: 0), in: result),
                  let numberRange = Range(match.range(at: 1), in: result),
                  let unitRange = Range(match.range(at: 2), in: result),
                  let amount = parsedAmount(
                    String(result[numberRange]),
                    unit: String(result[unitRange]).lowercased()
                  ) else {
                continue
            }
            result.replaceSubrange(fullRange, with: formatted(amount))
        }
        return result
    }

    static func formatted(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let number = formatter.string(from: NSNumber(value: max(0, amount))) ?? String(max(0, amount))
        return "Rp \(number)"
    }

    private static func firstRangeMidpoint(in text: String) -> RupiahAmount? {
        let pattern = #"(?i)\bRp\s*([0-9]+(?:[.,][0-9]+)*)\s*(juta|jt|ribu|rb|k)?\s*(?:-|–|—|sampai|hingga|to)\s*(?:Rp\s*)?([0-9]+(?:[.,][0-9]+)*)\s*(juta|jt|ribu|rb|k)?"#
        guard let expression = try? NSRegularExpression(pattern: pattern),
              let match = expression.firstMatch(
                in: text,
                range: NSRange(text.startIndex..., in: text)
              ) else {
            return nil
        }

        let firstNumber = capturedString(at: 1, from: match, in: text)
        let secondNumber = capturedString(at: 3, from: match, in: text)
        let firstExplicitUnit = capturedString(at: 2, from: match, in: text).lowercased()
        let secondExplicitUnit = capturedString(at: 4, from: match, in: text).lowercased()
        let firstUnit = firstExplicitUnit.isEmpty ? secondExplicitUnit : firstExplicitUnit
        let secondUnit = secondExplicitUnit.isEmpty ? firstExplicitUnit : secondExplicitUnit

        guard let firstAmount = parsedAmount(firstNumber, unit: firstUnit),
              let secondAmount = parsedAmount(secondNumber, unit: secondUnit) else {
            return nil
        }

        let lowerBound = min(firstAmount, secondAmount)
        let upperBound = max(firstAmount, secondAmount)
        let midpoint = lowerBound + ((upperBound - lowerBound) / 2)
        return RupiahAmount(value: midpoint, isEstimated: true)
    }

    private static func containsOpenEndedRange(in text: String) -> Bool {
        let pattern = #"(?i)(?:(?:mulai(?:\s+dari)?|minimal|setidaknya)\s*Rp\s*[0-9]|Rp\s*[0-9]+(?:[.,][0-9]+)*\s*(?:juta|jt|ribu|rb|k)?\s*(?:\+|ke atas))"#
        guard let expression = try? NSRegularExpression(pattern: pattern) else {
            return false
        }
        return expression.firstMatch(
            in: text,
            range: NSRange(text.startIndex..., in: text)
        ) != nil
    }

    private static func capturedString(
        at index: Int,
        from match: NSTextCheckingResult,
        in text: String
    ) -> String {
        guard let range = Range(match.range(at: index), in: text) else { return "" }
        return String(text[range])
    }

    private static func firstAmount(
        in text: String,
        matching pattern: String,
        unitCaptureIndex: Int? = 2
    ) -> Int? {
        guard let expression = try? NSRegularExpression(pattern: pattern),
              let match = expression.firstMatch(
                in: text,
                range: NSRange(text.startIndex..., in: text)
              ),
              let numberRange = Range(match.range(at: 1), in: text) else {
            return nil
        }

        let numberText = String(text[numberRange])
        let unit = unitCaptureIndex.map {
            capturedString(at: $0, from: match, in: text).lowercased()
        } ?? ""
        return parsedAmount(numberText, unit: unit)
    }

    private static func parsedAmount(_ numberText: String, unit: String) -> Int? {
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
