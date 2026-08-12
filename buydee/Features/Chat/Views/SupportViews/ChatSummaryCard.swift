import SwiftUI

struct ChatSummaryCard: View {
    let summary: DecisionSummary
    let isEnabled: Bool
    let onDecision: (PurchaseDecision) -> Void

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Take a look at this")
                    .font(.buydeeChatSummaryTitle)

                if !summary.context.isEmpty {
                    Text(ChatInlineMarkdownParser.parse(summary.context))
                        .font(.buydeeChatMessage)
                        .fixedSize(horizontal: false, vertical: true)
                }

                SummaryListSection(
                    title: "Pros",
                    systemImage: "checkmark.circle.fill",
                    items: summary.pros
                )

                SummaryListSection(
                    title: "Cons",
                    systemImage: "exclamationmark.circle.fill",
                    items: summary.cons
                )

                HStack(spacing: 12) {
                    decisionButton(for: .bye)
                    decisionButton(for: .buy)
                }
                .padding(.top, 12)
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
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(decision == .bye ? Color.buydee.background : Color.buydee.cardBackground)
        .clipShape(Capsule())
        .disabled(!isEnabled)
        .accessibilityHint(decision == .buy ? "Choose to buy now" : "Choose not to buy now")
    }
}

#Preview("Decision Summary") {
    if let summary = DecisionSummary(
        markdown: """
        Sebentar aku rangkum dulu ya—biar kamu bisa melihat seluruh gambarannya sebelum memilih.

        Kamu sedang mempertimbangkan **sepatu lari seharga Rp1.500.000**.

        **PROS:**
        - Model dan **warnanya** sesuai dengan yang kamu cari.
        - Terlihat nyaman untuk dipakai berlari.
        **CONS:**
        - Kamu sudah memiliki dua pasang sepatu serupa.
        - Kamu belum yakin akan sering memakainya.

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
