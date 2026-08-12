//
//  CameraGuideCard.swift
//  buydee
//

import SwiftUI

struct CameraGuideCard: View {
    let action: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image("CameraGuideIllustration")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 141, height: 118)
                .accessibilityHidden(true)

            Text("Take a clear photo of the item you’re thinking about buying so we can help guide your reflection.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.primary)
                .fixedSize(horizontal: false, vertical: true)

            Button(action: action) {
                Text("Got It")
                    .font(.headline)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 17))
            .controlSize(.large)
            .tint(Color.buydee.primaryButton)
            .accessibilityHint("Dismisses the camera guide")
        }
        .padding(.horizontal, 28)
        .padding(.vertical, 24)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 36, style: .continuous))
        .frame(maxWidth: 320)
        .environment(\.colorScheme, .light)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Camera guide")
    }

}
