//
//  AppFont.swift
//  buydee
//
import SwiftUI
extension Font {
    static let buydeeLargeTitle = Font.largeTitle.weight(.bold) // Emphasized
    static let buydeeTitle1 = Font.title.weight(.bold) // Emphasized
    static let buydeeTitle2 = Font.title2.weight(.bold) // Emphasized
    static let buydeeTitle3 = Font.title3.weight(.semibold) // Emphasized
    static let buydeeHeadline = Font.headline.weight(.semibold) // Default
    static let buydeeBody = Font.body // Default (Regular)
    static let buydeeCallout = Font.callout // Default (Regular)
    static let buydeeSubheadline = Font.subheadline // Default (Regular)
    static let buydeeFootnote = Font.footnote // Default (Regular)
    static let buydeeCaption1 = Font.caption // Default (Regular)
    static let buydeeCaption2 = Font.caption2 // Default (Regular)

    // MARK: - Chat

    static let buydeeChatMessage = Font.body
    static let buydeeChatButton = Font.callout.weight(.semibold)
    static let buydeeChatSummaryTitle = Font.headline.weight(.bold)
    static let buydeeChatCompletionTitle = Font.title2.weight(.bold)

    // MARK: - Markdown

    static let buydeeMarkdownHeading1 = Font.title.bold()
    static let buydeeMarkdownHeading2 = Font.title2.bold()
    static let buydeeMarkdownHeading3 = Font.title3.bold()
    static let buydeeMarkdownHeading4 = Font.headline.bold()
    static let buydeeMarkdownHeading5 = Font.subheadline.bold()
    static let buydeeMarkdownHeading6 = Font.footnote.bold()
    static let buydeeMarkdownInlineCode = Font.body.monospaced()
    static let buydeeMarkdownCodeBlock = Font.callout.monospaced()
}
