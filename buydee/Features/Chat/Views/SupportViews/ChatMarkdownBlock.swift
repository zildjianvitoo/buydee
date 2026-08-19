import Foundation

enum ChatMarkdownBlock: Identifiable {
    case heading(id: Int, level: Int, content: String)
    case paragraph(id: Int, content: String)
    case unorderedList(id: Int, items: [String])
    case orderedList(id: Int, items: [String])
    case blockquote(id: Int, content: String)
    case codeBlock(id: Int, language: String?, code: String)

    var id: Int {
        switch self {
        case .heading(let id, _, _),
             .paragraph(let id, _),
             .unorderedList(let id, _),
             .orderedList(let id, _),
             .blockquote(let id, _),
             .codeBlock(let id, _, _):
            id
        }
    }

    var isHeading: Bool {
        if case .heading = self {
            return true
        }
        return false
    }
}
