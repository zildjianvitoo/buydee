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
                VStack(alignment: .leading, spacing: 20) {
                    Text("Tempted to buy")
                        .font(.buydeeLargeTitle)
                        .foregroundStyle(Color.buydee.primaryText)

                    Text("Bring it here before you checked out. I’ll help you pause, reflect, and decide if it’s really worth it.  ")
                        .font(.buydeeBody)
                        .foregroundStyle(Color.buydee.primaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
                .padding(.top, 36)
                .padding(.bottom, 30)
                Spacer()
                
                
                Spacer()
                
                Button(action: action) {
                    Text("Show me how")
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
            Image("bg-onboarding-1")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }
}

#Preview {
    OnboardingPage1View(action: {})
}
