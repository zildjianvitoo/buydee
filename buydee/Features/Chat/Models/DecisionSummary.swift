import Foundation

struct DecisionSummary: Equatable, Sendable {
    let context: String
    let pros: [String]
    let cons: [String]

    init?(markdown: String) {
        let lines = markdown.components(separatedBy: .newlines)
        var contextLines: [String] = []
        var parsedPros: [String] = []
        var parsedCons: [String] = []
        var section = 0

        for rawLine in lines {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            let normalizedLine = line.lowercased()

            if normalizedLine == "**pros:**" {
                section = 1
                continue
            }
            if normalizedLine == "**cons:**" {
                section = 2
                continue
            }
            if normalizedLine.contains("**buy**") && normalizedLine.contains("**bye**") {
                continue
            }
            guard !line.isEmpty else { continue }

            guard line.hasPrefix("- ") else {
                if section == 0,
                   !normalizedLine.hasPrefix("sebentar aku rangkum") {
                    contextLines.append(line)
                }
                continue
            }

            let cleanedLine = String(line.dropFirst(2))
                .trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cleanedLine.isEmpty else { continue }

            switch section {
            case 1:
                parsedPros.append(cleanedLine)
            case 2:
                parsedCons.append(cleanedLine)
            default:
                continue
            }
        }

        guard !parsedPros.isEmpty, !parsedCons.isEmpty else { return nil }
        context = contextLines.joined(separator: " ")
        pros = parsedPros
        cons = parsedCons
    }
}
