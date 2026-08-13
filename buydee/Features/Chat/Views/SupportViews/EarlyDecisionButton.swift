import SwiftUI

struct EarlyDecisionButton: View {
    let language: ChatLanguage
    let action: () -> Void

    var body: some View {
        Button(
            language.text(
                indonesian: "Sudah siap menentukan pilihan sekarang?",
                english: "Are you ready to decide now?"
            ),
            action: action
        )
            .font(.buydeeChatButton)
            .buttonStyle(.borderedProminent)
            .tint(Color.buydee.earthyOlive)
            .foregroundStyle(Color.white)
            .controlSize(.regular)
            .frame(minHeight: 44)
            .accessibilityHint(
                language.text(
                    indonesian: "Menghentikan chat dan langsung menampilkan Summary",
                    english: "Stops the chat and shows the Summary now"
                )
            )
    }
}
