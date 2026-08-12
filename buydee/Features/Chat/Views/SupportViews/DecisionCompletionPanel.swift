import SwiftUI

struct DecisionCompletionPanel: View {
    let decision: PurchaseDecision
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
                            Text("All Set!")
                                .font(.buydeeChatCompletionTitle)

                            Text(decision == .buy ? "You choose to buy." : "You choose not to buy.")
                                .font(.buydeeHeadline)
                        }
                        .multilineTextAlignment(.center)

                        Text(completionMessage)
                            .font(.buydeeChatMessage)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: 24)

                        Button(action: onDone) {
                            Text("I’m good to go!")
                                .font(.buydeeChatButton)
                                .foregroundStyle(buttonForeground)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(buttonBackground)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .accessibilityHint("Continues to the saved decision screen")
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
        switch decision {
        case .buy:
            "You decided to buy, and that’s totally okay. A mindful purchase is the one you choose, not the one you rush. Enjoy!"
        case .bye:
            "You reflected and chose what truly matters. Small choices today bring you closer to your goal. Keep it going!"
        }
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
    DecisionCompletionPanel(decision: .bye, onDone: {})
        .frame(width: 393, height: 500)
        .background(Color.buydee.chatBackground)
}

#Preview("BUY Completion Panel") {
    DecisionCompletionPanel(decision: .buy, onDone: {})
        .frame(width: 393, height: 500)
        .background(Color.buydee.chatBackground)
}
