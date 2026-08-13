import Foundation
import SwiftUI

struct DecisionSummary: Equatable, Sendable {
    let content: String
    let choicePrompt: String?
    let consideredPriceInRupiah: RupiahAmount?
    let metadata: DecisionMetadata?

    var displayMarkdown: String {
        guard let choicePrompt, !choicePrompt.isEmpty else { return content }
        return "\(content)\n\n\(choicePrompt)"
    }

    init?(
        markdown: String,
        metadata: DecisionMetadata? = nil,
        requiresChoicePrompt: Bool = true
    ) {
        let normalizedMarkdown = markdown.replacing("\r\n", with: "\n")
        var contentLines: [String] = []
        var parsedChoicePrompt: String?
        var hasConfirmedMidpointMarker = false
        var reachedProsOrConsSection = false

        for rawLine in normalizedMarkdown.components(separatedBy: "\n") {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            let normalizedLine = line.lowercased()

            if normalizedLine == Self.confirmedMidpointMarker.lowercased() {
                hasConfirmedMidpointMarker = true
                continue
            }
            if normalizedLine.contains("**buy**"),
               normalizedLine.contains("**bye**") {
                parsedChoicePrompt = line
                continue
            }
            if Self.isProsOrConsLabel(line) {
                reachedProsOrConsSection = true
                continue
            }
            if reachedProsOrConsSection {
                continue
            }
            if Self.isMarkdownHeading(line) {
                continue
            }
            contentLines.append(Self.removingListMarker(from: rawLine))
        }

        guard !requiresChoicePrompt || parsedChoicePrompt != nil else { return nil }
        let parsedContent = contentLines
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !parsedContent.isEmpty else { return nil }

        let rangePrice = Self.confirmedRangePrice(
            from: metadata,
            hasConfirmedMidpointMarker: hasConfirmedMidpointMarker
        )
        if metadata?.priceRangeLower != nil || metadata?.priceRangeUpper != nil {
            guard rangePrice != nil else { return nil }
        }

        let metadataPrice: RupiahAmount?
        if let priceInRupiah = metadata?.priceInRupiah, priceInRupiah > 0 {
            metadataPrice = RupiahAmount(value: priceInRupiah, isEstimated: false)
        } else if let originalPriceText = metadata?.originalPriceText {
            metadataPrice = RupiahCurrency.firstAmount(in: originalPriceText)
        } else {
            metadataPrice = nil
        }

        content = RupiahCurrency.expandingShorthand(in: parsedContent)
        choicePrompt = parsedChoicePrompt
        consideredPriceInRupiah = rangePrice
            ?? RupiahCurrency.firstAmount(in: parsedContent)
            ?? metadataPrice
        self.metadata = metadata
    }

    private static func confirmedRangePrice(
        from metadata: DecisionMetadata?,
        hasConfirmedMidpointMarker: Bool
    ) -> RupiahAmount? {
        guard hasConfirmedMidpointMarker,
              let lowerBound = metadata?.priceRangeLower,
              let upperBound = metadata?.priceRangeUpper,
              lowerBound > 0,
              upperBound >= lowerBound else {
            return nil
        }

        let midpoint = lowerBound + ((upperBound - lowerBound) / 2)
        return RupiahAmount(value: midpoint, isEstimated: true)
    }

    private static func isProsOrConsLabel(_ line: String) -> Bool {
        let normalized = line
            .replacingOccurrences(of: "#", with: "")
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: "_", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: ":"))
            .lowercased()
        return [
            "pros", "cons", "pros and cons", "pro dan kontra",
            "kelebihan", "kekurangan", "alasan membeli",
            "alasan tidak membeli",
        ].contains(normalized)
    }

    private static func isMarkdownHeading(_ line: String) -> Bool {
        let markerCount = line.prefix { $0 == "#" }.count
        guard (1...6).contains(markerCount), markerCount < line.count else {
            return false
        }
        let contentIndex = line.index(line.startIndex, offsetBy: markerCount)
        return line[contentIndex].isWhitespace
    }

    private static func removingListMarker(from line: String) -> String {
        let leadingWhitespace = line.prefix { $0.isWhitespace }
        let content = line.dropFirst(leadingWhitespace.count)

        for marker in ["- ", "* ", "+ "] where content.hasPrefix(marker) {
            return String(content.dropFirst(marker.count))
        }

        guard let separator = content.firstIndex(where: { $0 == "." || $0 == ")" }) else {
            return line
        }
        let possibleNumber = content[..<separator]
        guard !possibleNumber.isEmpty, possibleNumber.allSatisfy(\.isNumber) else {
            return line
        }
        let textStart = content.index(after: separator)
        return String(content[textStart...]).trimmingCharacters(in: .whitespaces)
    }

    private static let confirmedMidpointMarker = "<!-- BUYDEE_MIDPOINT_CONFIRMED -->"
}

#if DEBUG
#Preview("Decision Summary") {
    if let summary = DecisionSummary(
        markdown: """
        Oke, kayaknya udah kebayang sekarang. Kamu masih kepikiran **iPhone 17 seharga Rp17 juta** karena ponselmu rusak dan performanya memang menarik, tapi harganya juga masih terasa berat karena dana itu sedang kamu pertimbangkan untuk holiday fund.

        Kalau buat sekarang, kamu lebih condong ke **BUY** atau **BYE**?
        """,
        metadata: DecisionMetadata(
            productName: "iPhone 17",
            productCategory: "Smartphone",
            originalPriceText: "Rp17 juta",
            priceInRupiah: 17_000_000,
            contextSummary: "Ponsel sekarang rusak dan harga masih terasa berat.",
            relatedGoal: "Holiday fund"
        )
    ) {
        ChatSummaryCard(
            summary: summary,
            isEnabled: true,
            language: .indonesian,
            onDecision: { _ in }
        )
        .padding(16)
        .background(Color.buydee.chatBackground)
    }
}
#endif
