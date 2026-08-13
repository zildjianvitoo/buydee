import SwiftUI

struct ChatErrorBanner: View {
    let message: String
    let canRetry: Bool
    let language: ChatLanguage
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
                Button(
                    language.text(indonesian: "Coba lagi", english: "Retry"),
                    action: retry
                )
                    .font(.buydeeChatButton)
                    .frame(minHeight: 44)
            }
        }
        .padding(.horizontal, 16)
        .background(Color.buydee.cardBackground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(language.text(indonesian: "Kesalahan", english: "Error")): \(message)"
        )
    }
}
