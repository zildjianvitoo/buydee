import SwiftUI

struct ChatMessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if message.role == .user {
                Spacer(minLength: 24)
            }

            VStack(
                alignment: message.role == .assistant ? .leading : .trailing,
                spacing: 20
            ) {
                if let imageData = message.imageData,
                   let image = UIImage(data: imageData)
                {
                    let displaySize = imageDisplaySize(for: image)

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: displaySize.width, height: displaySize.height)
                        .clipped()
                        .clipShape(.rect(cornerRadius: 14))
                        .padding(8)
                        .background(bubbleColor)
                        .clipShape(.rect(cornerRadius: 20))
                        .overlay(alignment: message.role == .assistant ? .bottomLeading : .bottomTrailing) {
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.callout)
                                .foregroundStyle(bubbleColor)
                                .offset(
                                    x: message.role == .assistant ? 16 : -16,
                                    y: 12
                                )
                                .accessibilityHidden(true)
                        }
                        .accessibilityLabel(
                            message.role == .assistant
                                ? "Image from Buydee"
                                : "Your attached product image"
                        )
                }

                if !message.bubbleContent.isEmpty {
                    messageText
                        .textSelection(.enabled)
                        .font(.buydeeChatMessage)
                        .foregroundStyle(textColor)
                        .padding(16)
                        .background(bubbleColor)
                        .clipShape(.rect(cornerRadius: 20))
                        .overlay(alignment: message.role == .assistant ? .bottomLeading : .bottomTrailing) {
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.callout)
                                .foregroundStyle(bubbleColor)
                                .offset(
                                    x: message.role == .assistant ? 16 : -16,
                                    y: 12
                                )
                                .accessibilityHidden(true)
                        }
                        .accessibilityLabel(
                            "\(message.role == .assistant ? "Buydee" : "You"): \(message.bubbleContent)"
                        )
                }
            }
            .frame(
                maxWidth: 440,
                alignment: message.role == .assistant ? .leading : .trailing
            )
            
            if message.role == .assistant {
                Spacer(minLength: 24)
            }
        }
        .frame(
            maxWidth: .infinity,
            alignment: message.role == .assistant ? .leading : .trailing
        )
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var messageText: some View {
        if message.role == .assistant {
            ChatMarkdownText(message.bubbleContent)
        } else {
            Text(message.bubbleContent)
        }
    }

    private var bubbleColor: Color {
        message.role == .assistant
            ? Color.buydee.deepOliveGreen
            : Color.buydee.background
    }

    private var textColor: Color {
        message.role == .assistant
        ? Color.white
        : Color.black
    }

    private func imageDisplaySize(for image: UIImage) -> CGSize {
        guard image.size.width > 0, image.size.height > 0 else {
            return CGSize(width: 220, height: 220)
        }

        let widthScale = 220 / image.size.width
        let heightScale = 260 / image.size.height
        let scale = min(widthScale, heightScale)

        return CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )
    }

}

#Preview {
    ChatMessageBubble(
        message:
        ChatMessage(
            role: .assistant,
            content: "Kamu suka tampilannya, tapi juga sadar sudah punya pilihan yang mirip.\n\n# Soal kepakainya\nKamu membayangkan sepatu ini bakal dipakai untuk situasi apa?"
        )
    )
}
