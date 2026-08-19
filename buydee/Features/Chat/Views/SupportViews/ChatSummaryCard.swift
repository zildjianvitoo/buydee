import SwiftUI

struct ChatSummaryCard: View {
    let summary: DecisionSummary
    let isEnabled: Bool
    let language: ChatLanguage
    let onDecision: (PurchaseDecision) -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                if !summary.displayMarkdown.isEmpty {
                    ChatMarkdownText(summary.displayMarkdown)
                        .font(.buydeeChatMessage)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 12) {
                    decisionButton(for: .bye)
                    decisionButton(for: .buy)
                }
                .padding(.top, 4)
            }
            .foregroundStyle(Color.white)
            .padding(16)
            .frame(maxWidth: 460, alignment: .leading)
            .background(Color.buydee.deepOliveGreen)
            .clipShape(.rect(cornerRadius: 20))
            .textSelection(.enabled)

            Spacer(minLength: 24)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func decisionButton(for decision: PurchaseDecision) -> some View {
        Button {
            onDecision(decision)
        } label: {
            Text(decision.rawValue.uppercased())
                .font(.buydeeChatButton)
                .foregroundStyle(decision == .bye ? Color.buydee.deepOliveGreen : Color.buydee.mutedReddishBrown)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .background(decision == .bye ? Color.buydee.background : Color.buydee.cardBackground)
        .clipShape(Capsule())
        .disabled(!isEnabled)
        .accessibilityHint(
            language.text(
                indonesian: decision == .buy
                    ? "Pilih untuk membeli sekarang"
                    : "Pilih untuk tidak membeli sekarang",
                english: decision == .buy
                    ? "Choose to buy now"
                    : "Choose not to buy now"
            )
        )
    }
}

#Preview("Decision Summary") {
    if let summary = DecisionSummary(
        markdown: """
        Oke, poin besarnya kurang lebih gini sih. Kamu masih kepikiran **sepatu lari Rp1.500.000** ini karena desainnya memang kamu suka dan kebayang bakal sering dipakai, tapi harganya juga masih bikin kamu mikir karena kamu sudah punya dua pasang untuk kebutuhan serupa.

        Kalau buat sekarang, kamu lebih condong ke **BUY** atau **BYE**?
        """,
        metadata: DecisionMetadata(
            productName: "Sepatu lari",
            productCategory: "Sepatu",
            originalPriceText: "Rp1.500.000",
            priceInRupiah: 1_500_000,
            contextSummary: "Desain disukai tetapi sudah ada dua pasang serupa."
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
