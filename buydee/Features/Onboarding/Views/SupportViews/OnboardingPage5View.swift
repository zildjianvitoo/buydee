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
        ZStack {
            Image("BGOnboarding5")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                VStack(alignment: .leading, spacing: 21) {
                    Text("Let's make your goals\ncount!")
                        .font(.buydeeTitle1)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.buydee.primaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("We'll keep your goals in mind\nwhenever you're thinking about buying\nsomething.")
                        .font(.buydeeHeadline)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.buydee.primaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
                .padding(.top, 70)

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
                .padding(.bottom, 100)
            }
        }
    }
}

#Preview {
    OnboardingPage5View(action: {})
}
