import SwiftUI

struct ChatComposerView: View {
    @Binding var text: String
    let attachment: DraftImageAttachment?
    let isGenerating: Bool
    let isProcessingImage: Bool
    let canSend: Bool
    let canAttachImage: Bool
    let language: ChatLanguage
    @FocusState.Binding var isTextFieldFocused: Bool
    let openCamera: () -> Void
    let removeImage: () -> Void
    let send: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let attachment {
                HStack {
                    DraftImagePreviewView(
                        attachment: attachment,
                        remove: removeImage
                    )

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity)
                .contentShape(.rect)
                .onTapGesture {
                    isTextFieldFocused = false
                }
            }

            HStack(spacing: 8) {
                TextField(
                    language.text(
                        indonesian: "Tulis pesan",
                        english: "Type a message"
                    ),
                    text: $text,
                    prompt: Text(
                        language.text(
                            indonesian: "Tulis pesan...",
                            english: "Type a message..."
                        )
                    )
                    .foregroundStyle(Color.buydee.primaryText.opacity(0.5)),
                    axis: .vertical
                )
                    .font(.buydeeChatMessage)
                    .foregroundStyle(Color.buydee.primaryText)
                    .lineLimit(1...5)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.buydee.coolGray)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.buydee.oliveGreen, lineWidth: 1)
                    )
                    .focused($isTextFieldFocused)
                    .submitLabel(.send)
                    .onSubmit(sendIfPossible)
                    .disabled(!canAttachImage)
                    

                Button {
                    sendIfPossible()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.buydee.primaryText)
                }
                .padding(8)
                .background(Color.buydee.background)
                .clipShape(Circle())
                .disabled(!canSend)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.buydee.chatBackground)
    }

    private func sendIfPossible() {
        guard canSend else { return }
        send()
    }
}

#Preview("Chat Composer") {
    @Previewable @State var text = "Sepatu ini harganya Rp1.500.000"

    ChatComposerView(
        text: $text,
        attachment: nil,
        isGenerating: false,
        isProcessingImage: false,
        canSend: true,
        canAttachImage: true,
        language: .english,
        isTextFieldFocused: FocusState<Bool>().projectedValue,
        openCamera: {},
        removeImage: {},
        send: {}
    )
    .background(Color.buydee.chatBackground)
}
