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
        ZStack {
            Image("BG-onboarding-2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                VStack {
                    Text("Let's take another look before you buy!")
                        .font(Font.buydeeLargeTitle)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color.buydee.primaryText)

                    Text("I’ll be here whenever you’re thinking about buying something!")
                        .font(Font.buydeeTitle3)
                        .padding(.top, 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(Color.buydee.primaryText)
                }
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
                
                VStack {
                    Button(action: action) {
                        Text("Show Me")
                            .font(Font.buydeeHeadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 48)
                            .background(Color.buydee.primaryButton)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 16)
                            )
                    }
                }
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 30)
        }
    }

    func iconCircle(icon: String) -> some View {
        ZStack {
            Circle()
                .fill(Color.buydee.background)
                .frame(width: 76, height: 76)

            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(Color.buydee.primaryText)
        }
    }
}

#Preview {
    OnboardingPage2View(action: {})
}
