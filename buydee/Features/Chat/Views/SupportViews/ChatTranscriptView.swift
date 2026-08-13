import SwiftUI

struct ChatTranscriptView: View {
    let messages: [ChatMessage]
    let isGenerating: Bool
    let language: ChatLanguage
    let dismissKeyboard: () -> Void
    let onDecision: (PurchaseDecision) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showsScrollDownButton = false

    var body: some View {
        ScrollViewReader { proxy in
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    LazyVStack(spacing: 20) {
                        if !messages.isEmpty {
                            ForEach(messages) { message in
                                if message.id == summaryMessage?.id,
                                   let decisionSummary {
                                    ChatSummaryCard(
                                        summary: decisionSummary,
                                        isEnabled: !isGenerating,
                                        language: language,
                                        onDecision: onDecision
                                    )
                                    .id(message.id)
                                } else {
                                    ChatMessageBubble(message: message)
                                        .id(message.id)
                                }
                            }
                        }

                        if isGenerating {
                            ChatTypingIndicator(language: language)
                                .id("chat-typing-indicator")
                        }

                        Color.clear
                            .frame(height: 1)
                            .padding(.bottom, 24)
                            .id("chat-transcript-bottom")
                            .accessibilityHidden(true)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                }
                .contentShape(.rect)
                .onTapGesture(perform: dismissKeyboard)
                .scrollDismissesKeyboard(.interactively)
                .scrollIndicators(.hidden)
                .defaultScrollAnchor(.bottom)
                .onScrollGeometryChange(for: Bool.self) { geometry in
                    let hasScrollableContent =
                        geometry.contentSize.height > geometry.visibleRect.height + 1
                    let distanceFromBottom =
                        geometry.contentSize.height - geometry.visibleRect.maxY
                    return hasScrollableContent && distanceFromBottom > 8
                } action: { _, isAwayFromBottom in
                    showsScrollDownButton = isAwayFromBottom
                }
                .task {
                    scrollToLatest(using: proxy)
                }
                .onChange(of: messages.count) { _, _ in
                    scrollToLatest(using: proxy)
                }
                .onChange(of: isGenerating) { _, _ in
                    scrollToLatest(using: proxy)
                }

                if messages.isEmpty && !isGenerating {
                    ContentUnavailableView {
                        Label(
                            language.text(
                                indonesian: "Apa yang sedang kamu pertimbangkan?",
                                english: "What are you considering?"
                            ),
                            systemImage: "bubble.left.and.bubble.right"
                        )
                        .foregroundStyle(.black)
                    } description: {
                        Text(
                            language.text(
                                indonesian: "Tulis nama produk dan harganya, atau lampirkan gambar untuk mulai.",
                                english: "Type a product and its price, or attach an image to begin."
                            )
                        )
                            .foregroundStyle(.black)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(.rect)
                    .onTapGesture(perform: dismissKeyboard)
                }

                if showsScrollDownButton {
                    Button(
                        language.text(
                            indonesian: "Scroll ke pesan terbaru",
                            english: "Scroll to latest message"
                        ),
                        systemImage: "chevron.down"
                    ) {
                        scrollToLatest(using: proxy)
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderedProminent)
                    .clipShape(Circle())
                    .controlSize(.large)
                    .frame(width: 52, height: 52)
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                    .accessibilityHint(
                        language.text(
                            indonesian: "Berpindah ke pesan paling baru",
                            english: "Moves to the newest message"
                        )
                    )
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .animation(.easeOut, value: showsScrollDownButton)
        }
    }

    private var summaryMessage: ChatMessage? {
        guard !isGenerating,
              let latestAssistant = messages.last(where: { $0.role == .assistant }),
              latestAssistant.decisionSummary != nil else {
            return nil
        }
        return latestAssistant
    }

    private var decisionSummary: DecisionSummary? {
        guard let summaryMessage else { return nil }
        return summaryMessage.decisionSummary
    }

    private func scrollToLatest(using proxy: ScrollViewProxy) {
        Task { @MainActor in
            await Task.yield()

            if reduceMotion {
                proxy.scrollTo("chat-transcript-bottom", anchor: .bottom)
            } else {
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo("chat-transcript-bottom", anchor: .bottom)
                }
            }
        }
    }
}
