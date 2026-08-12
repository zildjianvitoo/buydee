import SwiftUI

struct DecisionCompletionPanel: View {
    let decision: PurchaseDecision
    let onDone: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let circleDiameter = proxy.size.width * 1.5
            let circleRadius = circleDiameter / 2
            let halfScreenWidth = proxy.size.width / 2
            let arcDepth = circleRadius - sqrt(
                max(0, (circleRadius * circleRadius) - (halfScreenWidth * halfScreenWidth))
            )
            let topContentPadding = arcDepth + 48
            let bottomContentPadding = max(proxy.safeAreaInsets.bottom, 24) + 16

            ZStack(alignment: .top) {
                Circle()
                    .fill(panelBackground)
                    .frame(width: circleDiameter, height: circleDiameter)
                    .offset(x: (proxy.size.width - circleDiameter) / 2)

                panelBackground
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, arcDepth)

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
                    .frame(
                        maxWidth: 560,
                        minHeight: max(
                            0,
                            proxy.size.height - topContentPadding - bottomContentPadding
                        )
                    )
                    .padding(.horizontal, 32)
                    .padding(.top, topContentPadding)
                    .padding(.bottom, bottomContentPadding)
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
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
