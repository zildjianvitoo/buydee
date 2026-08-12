//
//  OnboardingPage1View.swift
//  buydee
//
//  Created by Muhammad Muttakin on 11/08/26.
//

import SwiftUI

struct OnboardingPage1View: View {
    // MARK: - Properties
    var action: () -> Void

    // MARK: - Body
    var body: some View {
        VStack {
                Text("Hi, there!\nI’ll be your personal shopping buddy.")
                    .font(.buydeeLargeTitle)
                    .foregroundStyle(Color.buydee.primaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 32)
                    .padding(.top, 36)
                Spacer()
                
                ZStack {
                    Image("otter")

                }
                Spacer()
                
                Button(action: action) {
                    Text("Bring me along")
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
            Image("BG-onboarding-1")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}

#Preview {
    OnboardingPage1View(action: {})
}
