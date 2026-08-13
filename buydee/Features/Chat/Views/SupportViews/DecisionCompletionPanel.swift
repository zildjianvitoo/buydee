import SwiftUI

struct DecisionCompletionPanel: View {
    let decision: PurchaseDecision
    let language: ChatLanguage
    let onDone: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let circleDiameter = proxy.size.width * 2
            let circleRadius = circleDiameter / 2
            let halfScreenWidth = proxy.size.width / 2
            let arcDepth = circleRadius - sqrt(
                max(0, (circleRadius * circleRadius) - (halfScreenWidth * halfScreenWidth))
            )
            let contentWidth = min(max(0, proxy.size.width - 64), 560)
            let topContentPadding = arcDepth + 24
            let bottomContentPadding = max(proxy.safeAreaInsets.bottom, 24) + 88

            ZStack(alignment: .top) {
                panelBackground
                    .frame(
                        width: proxy.size.width,
                        height: max(0, proxy.size.height - arcDepth)
                    )
                    .offset(y: arcDepth)

                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text(
                                language.text(
                                    indonesian: "Selesai!",
                                    english: "All Set!"
                                )
                            )
                                .font(.buydeeChatCompletionTitle)

                            Text(decisionText)
                                .font(.buydeeHeadline)
                        }
                        .multilineTextAlignment(.center)

                        Text(completionMessage)
                            .font(.buydeeChatMessage)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 24)

                        Button(action: onDone) {
                            Text(
                                language.text(
                                    indonesian: "Aku siap lanjut!",
                                    english: "I’m good to go!"
                                )
                            )
                                .font(.buydeeChatButton)
                                .foregroundStyle(buttonForeground)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(buttonBackground)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .accessibilityHint(
                            language.text(
                                indonesian: "Kembali ke beranda setelah keputusan disimpan",
                                english: "Returns home after saving the decision"
                            )
                        )
                    }
                    .foregroundStyle(panelForeground)
                    .frame(width: contentWidth)
                    .frame(
                        minHeight: max(
                            0,
                            proxy.size.height - topContentPadding - bottomContentPadding
                        )
                    )
                    .padding(.top, topContentPadding)
                    .padding(.bottom, bottomContentPadding)
                    .frame(width: proxy.size.width, alignment: .center)
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .scrollIndicators(.hidden)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .background(alignment: .top) {
                Circle()
                    .fill(panelBackground)
                    .frame(width: circleDiameter, height: circleDiameter)
            }
            .clipped()
        }
    }

    private var completionMessage: String {
        switch (decision, language) {
        case (.buy, .indonesian):
            "Kamu memilih untuk membeli dan itu sepenuhnya keputusanmu. Pembelian yang lebih sadar datang dari pilihan yang kamu buat tanpa terburu-buru."
        case (.bye, .indonesian):
            "Kamu sudah berhenti sejenak dan memilih hal yang paling sesuai untukmu sekarang."
        case (.buy, .english):
            "You decided to buy, and that is entirely your choice. A mindful purchase comes from a decision you make without rushing."
        case (.bye, .english):
            "You paused to reflect and chose what fits you best right now."
        }
    }

    private var decisionText: String {
        language.text(
            indonesian: decision == .buy
                ? "Kamu memilih untuk membeli."
                : "Kamu memilih untuk tidak membeli.",
            english: decision == .buy
                ? "You choose to buy."
                : "You choose not to buy."
        )
    }

    private var panelBackground: Color {
        decision == .buy
            ? Color.buydee.chatByeBackground
            : Color.buydee.background
    }

    private var panelForeground: Color {
        decision == .buy
            ? Color.buydee.cardBackground
            : Color.buydee.primaryText
    }

    private var buttonBackground: Color {
        decision == .buy ? Color.buydee.cardBackground : Color.buydee.primaryButton
    }

    private var buttonForeground: Color {
        decision == .buy ? Color.buydee.primaryText : Color.buydee.cardBackground
    }
}

#Preview("BYE Completion Panel") {
    DecisionCompletionPanel(decision: .bye, language: .english, onDone: {})
        .frame(width: 393, height: 500)
        .background(Color.buydee.chatBackground)
}

#Preview("BUY Completion Panel") {
    DecisionCompletionPanel(decision: .buy, language: .english, onDone: {})
        .frame(width: 393, height: 500)
        .background(Color.buydee.chatBackground)
}
