import SwiftUI

struct ChatTypingIndicator: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private static let messages = [
        "Bentar ya, aku lagi bantu kamu nimbang-nimbang dulu…",
        "Aku lagi bantu kamu lihat pertimbangannya biar lebih jelas…",
        "Sebentar ya, aku lagi nyusun sudut pandangnya buat kamu…",
        "Lagi aku pikirin bareng kamu, tunggu sebentar ya…",
    ]

    var body: some View {
        HStack {
            TimelineView(.animation(minimumInterval: 1.0 / 120.0, paused: reduceMotion)) { timeline in
                let message = message(at: timeline.date)

                Text(message)
                    .font(.buydeeChatMessage.bold())
                    .foregroundStyle(Color.buydee.oliveGreen)
                    .overlay {
                        GeometryReader { proxy in
                            LinearGradient(
                                colors: [
                                    .clear,
                                    Color.buydee.deepOliveGreen,
                                    .clear,
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: proxy.size.width * 0.5)
                            .offset(x: shimmerOffset(for: proxy.size.width, at: timeline.date))
                            .opacity(reduceMotion ? 0 : 0.9)
                        }
                        .mask {
                            Text(message)
                                .font(.buydeeChatMessage.bold())
                        }
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                    }
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 24)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Buydee sedang membantu memikirkan jawaban")
    }

    private func shimmerOffset(for width: Double, at date: Date) -> Double {
        let duration = 1.8
        let progress = date.timeIntervalSinceReferenceDate
            .truncatingRemainder(dividingBy: duration) / duration
        let shimmerWidth = width * 0.55
        return -shimmerWidth + ((width + shimmerWidth) * progress)
    }

    private func message(at date: Date) -> String {
        let displayDuration = 3.5
        let index = Int(date.timeIntervalSinceReferenceDate / displayDuration)
            % Self.messages.count
        return Self.messages[index]
    }
}

#Preview {
    ChatTypingIndicator()
        .padding()
        .background(Color.buydee.chatBackground)
}
