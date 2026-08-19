//
//  OnboardingPage2View.swift
//  buydee
//
//  Created by Muhammad Muttakin on 11/08/26.
//

import SwiftUI

struct OnboardingPage2View: View {
    // MARK: - Properties
    var action: () -> Void

    // MARK: - Body
    var body: some View {
        VStack {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Let's take another look before you buy!")
                        .font(.buydeeLargeTitle)
                        .foregroundStyle(Color.buydee.primaryText)

                    Text("I’ll be here whenever you’re thinking about buying something!")
                        .font(.buydeeBody)
                        .foregroundStyle(Color.buydee.primaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
                .padding(.top, 36)
                .padding(.bottom, 30)

                ZStack {
                    VStack {
                        iconCircle(icon: "hat.widebrim.fill")

                        HStack {
                            iconCircle(icon: "bag.fill")

                            Spacer()

                            iconCircle(icon: "sunglasses")
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 250)

                    Image("otter")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                        .offset(y: 10)
                }
                
                Spacer()
                Button(action: action) {
                    Text("Show Me")
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
            Image("BG-onboarding-2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
    }

    // MARK: - Private Methods
    func iconCircle(icon: String) -> some View {
        ZStack {
            Circle()
                .fill(Color.buydee.background)
                .frame(width: 76, height: 76)

            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundStyle(Color.buydee.primaryText)
        }
    }
}

#Preview {
    OnboardingPage2View(action: {})
}
