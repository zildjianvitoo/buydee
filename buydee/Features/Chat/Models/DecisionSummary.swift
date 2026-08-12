import Foundation
import SwiftUI

struct DecisionSummary: Equatable, Sendable {
    let content: String
    let consideredPriceInRupiah: RupiahAmount?
    let metadata: DecisionMetadata?

    init?(
        markdown: String,
        metadata: DecisionMetadata? = nil,
        requiresChoicePrompt: Bool = true
    ) {
        let normalizedMarkdown = markdown.replacing("\r\n", with: "\n")
        var contentLines: [String] = []
        var hasChoicePrompt = false
        var hasConfirmedMidpointMarker = false

        for rawLine in normalizedMarkdown.components(separatedBy: "\n") {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            let normalizedLine = line.lowercased()

            if normalizedLine == Self.confirmedMidpointMarker.lowercased() {
                hasConfirmedMidpointMarker = true
                continue
            }
            if normalizedLine.contains("**buy**"),
               normalizedLine.contains("**bye**") {
                hasChoicePrompt = true
                continue
            }
            contentLines.append(rawLine)
        }

        guard !requiresChoicePrompt || hasChoicePrompt else { return nil }
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
        if let originalPriceText = metadata?.originalPriceText {
            metadataPrice = RupiahCurrency.firstAmount(in: originalPriceText)
        } else {
            metadataPrice = nil
        }

        content = parsedContent
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
            contextSummary: "Ponsel sekarang rusak dan harga masih terasa berat.",
            prosSummary: "Performa menarik dan akan sering dipakai.",
            consSummary: "Harga bersaing dengan holiday fund.",
            relatedGoal: "Holiday fund"
        )
    ) {
        ChatSummaryCard(
            summary: summary,
            isEnabled: true,
            onDecision: { _ in }
        )
        .padding(16)
        .background(Color.buydee.chatBackground)
    }
}
#endif
