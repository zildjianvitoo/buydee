import SwiftUI

struct ChatMarkdownBlockView: View {
    let block: ChatMarkdownBlock

    var body: some View {
        switch block {
        case .heading(_, let level, let content):
            Text(ChatInlineMarkdownParser.parse(content))
                .font(headingFont(for: level))
                .fixedSize(horizontal: false, vertical: true)

        case .paragraph(_, let content):
            Text(ChatInlineMarkdownParser.parse(content))
                .font(.buydeeChatMessage)
                .fixedSize(horizontal: false, vertical: true)

        case .unorderedList(_, let items):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("•")
                            .accessibilityHidden(true)
                        Text(ChatInlineMarkdownParser.parse(item))
                    }
                }
            }

        case .orderedList(_, let items):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(index + 1).")
                        Text(ChatInlineMarkdownParser.parse(item))
                    }
                }
            }

        case .blockquote(_, let content):
            HStack(alignment: .top, spacing: 10) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.buydee.background)
                    .frame(width: 3)
                    .accessibilityHidden(true)

                Text(ChatInlineMarkdownParser.parse(content))
                    .italic()
                    .fixedSize(horizontal: false, vertical: true)
            }

        case .codeBlock(_, let language, let code):
            ScrollView(.horizontal) {
                VStack(alignment: .leading, spacing: 8) {
                    if let language {
                        Text(language.uppercased())
                            .font(.caption)
                            .foregroundStyle(Color.buydee.secondaryText)
                    }

                    Text(code)
                        .font(.buydeeMarkdownCodeBlock)
                        .textSelection(.enabled)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .padding(12)
            }
            .scrollIndicators(.hidden)
            .background(Color.buydee.chatCodeBackground)
            .clipShape(.rect(cornerRadius: 12))
            .accessibilityLabel(language.map { "Code block, \($0)" } ?? "Code block")
        }
    }

    private func headingFont(for level: Int) -> Font {
        switch level {
        case 1: .buydeeMarkdownHeading1
        case 2: .buydeeMarkdownHeading2
        case 3: .buydeeMarkdownHeading3
        case 4: .buydeeMarkdownHeading4
        case 5: .buydeeMarkdownHeading5
        default: .buydeeMarkdownHeading6
        }
    }
}
