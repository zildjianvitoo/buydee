import Foundation
import SwiftUI

struct DecisionSummary: Equatable, Sendable {
    let context: String
    let pros: [String]
    let cons: [String]
    let consideredPriceInRupiah: RupiahAmount?

    init?(markdown: String) {
        let lines = markdown.components(separatedBy: .newlines)
        var contextLines: [String] = []
        var parsedPros: [String] = []
        var parsedCons: [String] = []
        var hasConfirmedMidpointMarker = false
        var section = 0

        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            let normalizedLine = line.lowercased()

            if normalizedLine == Self.confirmedMidpointMarker.lowercased() {
                hasConfirmedMidpointMarker = true
                continue
            }
            if normalizedLine == "**pros:**" {
                section = 1
                continue
            }
            if normalizedLine == "**cons:**" {
                section = 2
                continue
            }
            if normalizedLine.contains("**buy**") && normalizedLine.contains("**bye**") {
                continue
            }
            guard !line.isEmpty else { continue }

            guard line.hasPrefix("- ") else {
                if section == 0,
                   !normalizedLine.hasPrefix("sebentar aku rangkum") {
                    contextLines.append(line)
                }
                continue
            }

            let cleanedLine = String(line.dropFirst(2))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleanedLine.isEmpty else { continue }

            switch section {
            case 1:
                parsedPros.append(cleanedLine)
            case 2:
                parsedCons.append(cleanedLine)
            default:
                continue
            }
        }

        guard !parsedPros.isEmpty, !parsedCons.isEmpty else { return nil }
        let parsedContext = contextLines.joined(separator: " ")
        let parsedPrice = RupiahCurrency.firstAmount(in: parsedContext)
        guard parsedPrice?.isEstimated != true || hasConfirmedMidpointMarker else {
            return nil
        }

        context = parsedContext
        pros = parsedPros
        cons = parsedCons
        consideredPriceInRupiah = parsedPrice
    }

    private static let confirmedMidpointMarker = "<!-- BUYDEE_MIDPOINT_CONFIRMED -->"
}

#Preview("Decision Summary") {
    if let summary = DecisionSummary(
        markdown: """
        Sebentar aku rangkum dulu ya—biar kamu bisa melihat seluruh gambarannya sebelum memilih.

        Kamu sedang mempertimbangkan **iPhone 17 seharga Rp17 juta** karena ponsel yang sekarang rusak.

        **PROS:**
        - Performa iPhone 17 menarik buat kamu.
        - Ponsel baru akan sering dipakai sehari-hari.
        **CONS:**
        - Harganya terasa terlalu mahal.
        - Dana tersebut juga sedang dipertimbangkan untuk **holiday fund**.

        Kamu mau pilih **BUY** atau **BYE**?
        """
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
