import SwiftUI

struct DecisionCompletionView: View {
    let decision: PurchaseDecision
    let consideredPriceInRupiah: RupiahAmount?
    let language: ChatLanguage
    let onDone: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let panelHeight = proxy.size.height * 0.53
            let panelTop = proxy.size.height - panelHeight
            let mascotWidth = min(proxy.size.width * 0.5, 240)
            let mascotHeight = mascotWidth * (193.0 / 200.0)
            let mascotPanelOverlap: CGFloat = 18

            ZStack(alignment: .top) {
                Color.buydee.chatBackground

                if decision == .bye {
                    Text(byeHeadline)
                        .font(.buydeeChatCompletionTitle)
                        .foregroundStyle(Color.buydee.primaryText)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: min(proxy.size.width - 48, 560))
                        .position(
                            x: proxy.size.width / 2,
                            y: max(proxy.safeAreaInsets.top + 164, panelTop * 0.4)
                        )
                }

                Image(mascotAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: mascotWidth, height: mascotHeight)
                    .position(
                        x: proxy.size.width / 2,
                        y: panelTop - (mascotHeight / 2) + mascotPanelOverlap
                    )
                    .accessibilityHidden(true)

                DecisionCompletionPanel(
                    decision: decision,
                    language: language,
                    onDone: onDone
                )
                    .frame(width: proxy.size.width, height: panelHeight)
                    .position(
                        x: proxy.size.width / 2,
                        y: panelTop + (panelHeight / 2)
                    )
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var byeHeadline: String {
        guard let consideredPriceInRupiah else {
            return language.text(
                indonesian: "Yeay! Kamu menghemat uang dari keputusan ini!",
                english: "Yeay! You saved money from this decision!"
            )
        }
        let estimatePrefix = consideredPriceInRupiah.isEstimated
            ? language.text(indonesian: "sekitar ", english: "around ")
            : ""
        return language.text(
            indonesian: "Yeay! Kamu menghemat \(estimatePrefix)\(RupiahCurrency.formatted(consideredPriceInRupiah.value)) dari keputusan ini!",
            english: "Yeay! You saved \(estimatePrefix)\(RupiahCurrency.formatted(consideredPriceInRupiah.value)) from this decision!"
        )
    }

    private var mascotAssetName: String {
        decision == .bye ? "img_bird_smile" : "img_bird_smile_open"
    }
}

#Preview("Screen 1 — BYE Completion") {
    DecisionCompletionView(
        decision: .bye,
        consideredPriceInRupiah: RupiahAmount(value: 750_000, isEstimated: false),
        language: .english,
        onDone: {}
    )
}

#Preview("Screen 2 — BUY Completion") {
    DecisionCompletionView(
        decision: .buy,
        consideredPriceInRupiah: RupiahAmount(value: 16_000_000, isEstimated: true),
        language: .english,
        onDone: {}
    )
}

#Preview("State — BYE with Confirmed Price Range") {
    DecisionCompletionView(
        decision: .bye,
        consideredPriceInRupiah: RupiahAmount(value: 16_000_000, isEstimated: true),
        language: .english,
        onDone: {}
    )
}
