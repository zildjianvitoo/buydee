import Foundation

enum ChatMarkdownParser {
    static func parse(_ markdown: String) -> [ChatMarkdownBlock] {
        let lines = markdown
            .replacingOccurrences(of: "\r\n", with: "\n")
            .components(separatedBy: "\n")
        var blocks: [ChatMarkdownBlock] = []
        var paragraphLines: [String] = []
        var lineIndex = 0
        var blockID = 0

        func append(_ block: ChatMarkdownBlock) {
            blocks.append(block)
            blockID += 1
        }

        func flushParagraph() {
            guard !paragraphLines.isEmpty else { return }
            append(.paragraph(id: blockID, content: paragraphLines.joined(separator: " ")))
            paragraphLines.removeAll(keepingCapacity: true)
        }

        while lineIndex < lines.count {
            let rawLine = lines[lineIndex]
            let trimmedLine = rawLine.trimmingCharacters(in: .whitespaces)

            if trimmedLine.hasPrefix("```") {
                flushParagraph()
                let languageValue = String(trimmedLine.dropFirst(3))
                    .trimmingCharacters(in: .whitespaces)
                var codeLines: [String] = []
                lineIndex += 1

                while lineIndex < lines.count,
                      !lines[lineIndex].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                    codeLines.append(lines[lineIndex])
                    lineIndex += 1
                }

                append(
                    .codeBlock(
                        id: blockID,
                        language: languageValue.isEmpty ? nil : languageValue,
                        code: codeLines.joined(separator: "\n")
                    )
                )
                lineIndex += lineIndex < lines.count ? 1 : 0
                continue
            }

            if trimmedLine.isEmpty {
                flushParagraph()
                lineIndex += 1
                continue
            }

            if let heading = heading(from: trimmedLine) {
                flushParagraph()
                append(.heading(id: blockID, level: heading.level, content: heading.content))
                lineIndex += 1
                continue
            }

            if unorderedItem(from: trimmedLine) != nil {
                flushParagraph()
                var items: [String] = []
                while lineIndex < lines.count,
                      let item = unorderedItem(
                        from: lines[lineIndex].trimmingCharacters(in: .whitespaces)
                      ) {
                    items.append(item)
                    lineIndex += 1
                }
                append(.unorderedList(id: blockID, items: items))
                continue
            }

            if orderedItem(from: trimmedLine) != nil {
                flushParagraph()
                var items: [String] = []
                while lineIndex < lines.count,
                      let item = orderedItem(
                        from: lines[lineIndex].trimmingCharacters(in: .whitespaces)
                      ) {
                    items.append(item)
                    lineIndex += 1
                }
                append(.orderedList(id: blockID, items: items))
                continue
            }

            if trimmedLine.hasPrefix(">") {
                flushParagraph()
                var quoteLines: [String] = []
                while lineIndex < lines.count {
                    let candidate = lines[lineIndex].trimmingCharacters(in: .whitespaces)
                    guard candidate.hasPrefix(">") else { break }
                    quoteLines.append(
                        String(candidate.dropFirst())
                            .trimmingCharacters(in: .whitespaces)
                    )
                    lineIndex += 1
                }
                append(.blockquote(id: blockID, content: quoteLines.joined(separator: " ")))
                continue
            }

            paragraphLines.append(trimmedLine)
            lineIndex += 1
        }

        flushParagraph()
        return blocks
    }

    private static func heading(from line: String) -> (level: Int, content: String)? {
        let hashCount = line.prefix { $0 == "#" }.count
        guard (1...6).contains(hashCount) else { return nil }

        let contentStart = line.index(line.startIndex, offsetBy: hashCount)
        guard contentStart < line.endIndex, line[contentStart].isWhitespace else { return nil }

        let content = line[contentStart...].trimmingCharacters(in: .whitespaces)
        guard !content.isEmpty else { return nil }
        return (hashCount, content)
    }

    private static func unorderedItem(from line: String) -> String? {
        for marker in ["- ", "* ", "+ "] where line.hasPrefix(marker) {
            let content = String(line.dropFirst(marker.count))
                .trimmingCharacters(in: .whitespaces)
            return content.isEmpty ? nil : content
        }
        return nil
    }

    private static func orderedItem(from line: String) -> String? {
        guard let markerIndex = line.firstIndex(where: { $0 == "." || $0 == ")" }) else {
            return nil
        }
        let number = line[..<markerIndex]
        guard !number.isEmpty, number.allSatisfy(\.isNumber) else { return nil }

        let contentStart = line.index(after: markerIndex)
        guard contentStart < line.endIndex, line[contentStart].isWhitespace else { return nil }

        let content = line[contentStart...].trimmingCharacters(in: .whitespaces)
        return content.isEmpty ? nil : content
    }
}
