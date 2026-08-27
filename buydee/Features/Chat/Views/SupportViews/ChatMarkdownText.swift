import SwiftUI

struct ChatMarkdownText: View {
    private let blocks: [ChatMarkdownBlock]

    init(_ markdown: String) {
        blocks = ChatMarkdownParser.parse(markdown)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(blocks.enumerated()), id: \.element.id) { index, block in
                ChatMarkdownBlockView(block: block)
                    .padding(.top, block.isHeading && index > 0 ? 10 : 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .tint(Color.buydee.background)
    }
}

#Preview("Markdown Elements") {
    ChatMarkdownText(
        """
        # Heading One
        ## Heading Two
        ### Heading Three
        #### Heading Four
        ##### Heading Five
        ###### Heading Six

        Teks dengan **bold**, *italic*, `inline code`, dan [link](https://example.com).

        - Unordered item
        - Item dengan **bold**

        1. Ordered item
        2. Item berikutnya

        > Pertimbangkan apa yang paling penting buat kamu.

        Teks ==penting yang disorot== dan marker tanpa penutup ==tetap apa adanya.

        ```swift
        let decision = "BUY atau BYE"
        print(decision)
        ```
        """
    )
        .foregroundStyle(.white)
        .padding()
        .background(Color.buydee.deepOliveGreen)
}
