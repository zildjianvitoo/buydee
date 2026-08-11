//
//  Color+Extensions.swift
//  buydee
//

import SwiftUI

extension Color {
    static let buydee = BuydeeColors()
}

struct BuydeeColors {
    /// Background color for onboarding (soft periwinkle / blueish grey)
    let background = Color(red: 0.72, green: 0.74, blue: 0.85) // #B8BDE9 approximate
    
    /// Accent color for buttons and primary text (dark charcoal grey)
    let primaryButton = Color(red: 0.35, green: 0.35, blue: 0.35) // #595959 approximate
    
    /// Text color for dark elements
    let primaryText = Color.primary
    
    /// Text color for descriptions
    let secondaryText = Color.secondary
    
    /// Card background color
    let cardBackground = Color.white
}
