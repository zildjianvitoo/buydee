//
//  OnboardingPage5View.swift
//  buydee
//
//  Created by Muhammad Muttakin on 12/08/26.
//

import SwiftUI

struct OnboardingPage5View: View {
    // MARK: - Properties
    var action: () -> Void

    // MARK: - Body
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 21) {
                Text("Ready to pause\nbefore you buy?")
                    .font(.buydeeLargeTitle)
                    .foregroundStyle(Color.buydee.primaryText)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Whenever temptation strikes, bring it here. We’ll take another look, together.")
                    .font(.buydeeBody)
                    .foregroundStyle(Color.buydee.primaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 32)
            .padding(.top, 36)

            Spacer()

            Button(action: action) {
                Text("Let's Get Started")
                    .font(.buydeeHeadline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.buydee.primaryButton)
                    .clipShape(RoundedRectangle(cornerRadius: BuydeeRadius.small))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .background(
            Image("bg-onboarding-5")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}

#Preview {
    OnboardingPage5View(action: {})
}
