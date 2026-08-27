//
//  CameraGuideCard.swift
//  buydee
//

import SwiftUI

struct CameraGuideCard: View {
    // MARK: - Properties
    let action: () -> Void
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 18) {
            Image("CameraGuideIllustration")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 141, height: 118)
                .accessibilityHidden(true)

            Text("Take a clear photo of the item you’re thinking about buying so we can help guide your reflection.")
                .font(.buydeeBody)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.buydee.primaryText)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: action) {
                Text("Got It")
                    .font(.buydeeHeadline)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: BuydeeRadius.small))
            .controlSize(.large)
            .tint(Color.buydee.primaryButton)
            .accessibilityHint("Dismisses the camera guide")
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 24)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: BuydeeRadius.medium, style: .continuous))
        .frame(maxWidth: 320)
        .environment(\.colorScheme, .light)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Camera guide")
    }

}
