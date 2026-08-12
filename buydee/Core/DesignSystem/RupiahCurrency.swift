import Foundation

enum RupiahCurrency {
    static func firstAmount(in text: String) -> RupiahAmount? {
        if let rangeAmount = firstRangeMidpoint(in: text) {
            return rangeAmount
        }
        guard !containsOpenEndedRange(in: text) else { return nil }

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
        let unit = capturedString(at: 2, from: match, in: text).lowercased()
        guard let amount = parsedAmount(numberText, unit: unit) else { return nil }
        return RupiahAmount(value: amount, isEstimated: false)
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
