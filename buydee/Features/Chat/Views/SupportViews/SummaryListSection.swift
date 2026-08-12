import SwiftUI

struct SummaryListSection: View {
    let title: String
    let systemImage: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.buydeeChatSummaryTitle)

            ForEach(items, id: \.self) { item in
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("•")
                        .accessibilityHidden(true)

                    Text(ChatInlineMarkdownParser.parse(item))
                        .font(.buydeeChatMessage)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .foregroundStyle(Color.white)
    }
}
