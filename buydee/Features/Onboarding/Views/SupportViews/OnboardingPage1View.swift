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
        ZStack{
            Image("BG-onboarding-1")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack {
                Text("Hi, There!\nI’ll be your personal shopping buddy.")
                    .font(Font.buydeeLargeTitle)
                    .foregroundStyle(Color.buydee.primaryText)
                    .padding(.top, 100)
                Spacer()
                
                ZStack {
                    Image("otter")

                }
                Spacer()
                
                Button(action: action) {
                    Text("Bring me along")
                        .font(.buydeeHeadline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color.buydee.primaryButton)
                        .clipShape(
                            RoundedRectangle(cornerRadius: BuydeeRadius.small)
                        )
                }
                .padding(.horizontal, 50)
                .padding(.bottom, 150)

            }
        }
        
        
    }
}

#Preview {
    OnboardingPage1View(action: {})
}
