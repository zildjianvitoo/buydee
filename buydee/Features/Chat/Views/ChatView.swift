import SwiftUI

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isComposerFocused: Bool

    @Bindable var viewModel: ChatViewModel
    let onDecision: (PurchaseDecision) -> Void
    let onCameraRequested: () -> Void

    var body: some View {
        ChatTranscriptView(
            messages: viewModel.messages,
            isGenerating: viewModel.isGenerating,
            language: viewModel.conversationLanguage,
            dismissKeyboard: dismissKeyboard,
            onDecision: chooseDecision
        )
        .background(Color.buydee.chatBackground)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                if let errorMessage = viewModel.errorMessage {
                    ChatErrorBanner(
                        message: errorMessage,
                        canRetry: viewModel.canRetry,
                        language: viewModel.conversationLanguage,
                        retry: viewModel.retryLastResponse
                    )
                }

                if viewModel.canOfferEarlyDecision && !viewModel.isGenerating {
                    EarlyDecisionButton(
                        language: viewModel.conversationLanguage,
                        action: viewModel.requestEarlySummary
                    )
                        .frame(maxWidth: 560, alignment: .leading)
                        .padding(.horizontal, 16)
                }

                ChatComposerView(
                    text: $viewModel.draftText,
                    attachment: viewModel.draftImage,
                    isGenerating: viewModel.isGenerating,
                    isProcessingImage: viewModel.isProcessingImage,
                    canSend: viewModel.canSend,
                    canAttachImage: viewModel.canAttachImage,
                    language: viewModel.conversationLanguage,
                    isTextFieldFocused: $isComposerFocused,
                    openCamera: onCameraRequested,
                    removeImage: viewModel.removeDraftImage,
                    send: viewModel.sendMessage
                )
                .frame(maxWidth: 560)
            }
            .frame(maxWidth: .infinity)
            .background(Color.clear)
        }
        .navigationTitle("Buydee")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(
                    viewModel.conversationLanguage.text(
                        indonesian: "Kembali",
                        english: "Back"
                    ),
                    systemImage: "chevron.left",
                    action: closeChat
                )
                .accessibilityHint(
                    viewModel.conversationLanguage.text(
                        indonesian: "Membatalkan sesi ini dan kembali ke beranda",
                        english: "Cancels this session and returns home"
                    )
                )
            }
        }
        .onChange(of: viewModel.completedDecision) { _, decision in
            guard let decision else { return }
            viewModel.consumeCompletedDecision()
            onDecision(decision)
        }
    }

    private func chooseDecision(_ decision: PurchaseDecision) {
        if viewModel.chooseDecision(decision) {
            onDecision(decision)
        }
    }

    private func closeChat() {
        viewModel.startNewConversation()
        dismiss()
    }

    private func dismissKeyboard() {
        isComposerFocused = false
    }
}

#Preview("Four Message Conversation") {
    @Previewable @State var viewModel: ChatViewModel = {
        let viewModel = ChatViewModel()
        viewModel.messages = [
            ChatMessage(
                role: .user,
                content: "Aku lagi kepikiran beli sepatu lari ini, harganya Rp1.500.000."
            ),
            ChatMessage(
                role: .assistant,
                content: "Modelnya memang kelihatan pas sama yang kamu cari.\n\n# Yang bikin kepincut\nBagian apa yang paling bikin kamu pengin punya sepatu ini?"
            ),
            ChatMessage(
                role: .assistant,
                content: "Warnanya bagus dan sepertinya nyaman, tapi aku sudah punya dua pasang."
            ),
            ChatMessage(
                role: .assistant,
                content: "Kamu suka tampilannya, tapi juga sadar sudah punya pilihan yang mirip.\n\n# Soal kepakainya\nKamu membayangkan sepatu ini bakal dipakai untuk situasi apa?"
            ),
        ]
        
        return viewModel
    }()

    NavigationStack {
        ChatView(
            viewModel: viewModel,
            onDecision: { _ in },
            onCameraRequested: {}
        )
    }
}
