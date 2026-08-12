import SwiftUI

struct ChatErrorBanner: View {
    let message: String
    let canRetry: Bool
    let retry: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.buydee.chatError)
                .accessibilityHidden(true)

            Text(message)
                .font(.buydeeSubheadline)
                .foregroundStyle(Color.buydee.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            if canRetry {
                Button("Retry", action: retry)
                    .font(.buydeeChatButton)
                    .frame(minHeight: 44)
            }
        }
        .padding(.horizontal, 16)
        .background(Color.buydee.cardBackground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message)")
    }
}
