import SwiftUI

struct DecisionCompletionView: View {
    let decision: PurchaseDecision
    let consideredPriceInRupiah: Int
    let onDone: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let panelHeight = proxy.size.height * 0.58
            let panelTop = proxy.size.height - panelHeight

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
                            y: max(proxy.safeAreaInsets.top + 72, panelTop * 0.52)
                        )
                }

                DecisionCompletionPanel(decision: decision, onDone: onDone)
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
        guard consideredPriceInRupiah > 0 else {
            return "Yeay! You saved money from this decision!"
        }
        return "Yeay! You saved \(RupiahCurrency.formatted(consideredPriceInRupiah)) from this decision!"
    }
}

#Preview("BYE Completion") {
    DecisionCompletionView(
        decision: .bye,
        consideredPriceInRupiah: 750_000,
        onDone: {}
    )
}

#Preview("BUY Completion") {
    DecisionCompletionView(
        decision: .buy,
        consideredPriceInRupiah: 750_000,
        onDone: {}
    )
}
