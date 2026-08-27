//
//  AppColor.swift
//  buydee
//
import SwiftUI
extension Color {
    static let buydee = BuydeeColors()

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
struct BuydeeColors {

    let background = Color(hex: "#E7E7D0")

    let primaryButton = Color(hex: "#54581A")
    let primaryText = Color(hex: "#332B20")
    let secondaryText = Color(hex: "#776E62")

    let linkText = Color(hex: "#1E2691")

    let cardBackground = Color.white
    let canvasBackground = Color(hex: "#FCF8F1")
    let secondaryBackground = Color(hex: "#F5F5F5") // Added fallback in case it's missing

    // MARK: - Chat

    let oliveGreen = Color(hex: "#778100")
    let lightOliveGreen = Color(hex: "#E8ECD7")
    let deepOliveGreen = Color(hex: "#404503")
    let earthyOlive = Color(hex: "#60480F")
    let coolGray = Color(hex: "#F2F2F7")
    let mutedReddishBrown = Color(hex: "#6C423A")
    let white = Color(hex: "#FFFFFF")

    let chatBackground = Color(hex: "#FAF7F2")
    let chatComposerBackground = Color(hex: "#F1F1F4")
    let chatComposerButton = Color(hex: "#DB7D5D")
    let chatComposerButtonForeground = Color(hex: "#FEFAF9")
    let chatComposerBorder = Color(hex: "#4F5420")
    let chatSummaryBackground = Color(hex: "#F2B0A6")
    let chatMascotPlaceholder = Color(hex: "#657184")
    let chatByeBackground = Color(hex: "#C47F65")
    let chatError = Color(hex: "#9D2F2F")
    let chatCodeBackground = Color.black.opacity(0.22)
}
