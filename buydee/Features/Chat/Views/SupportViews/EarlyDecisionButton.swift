import SwiftUI

struct EarlyDecisionButton: View {
    let action: () -> Void

    var body: some View {
        Button("Are you ready to decide now?", action: action)
            .font(.buydeeChatButton)
            .buttonStyle(.borderedProminent)
            .tint(Color.buydee.earthyOlive)
            .foregroundStyle(Color.white)
            .controlSize(.regular)
            .frame(minHeight: 44)
            .accessibilityHint("Ask Buydee to summarize the conversation now")
    }
}
