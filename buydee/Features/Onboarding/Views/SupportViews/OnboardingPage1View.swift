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
            Text("Hi, There!\nI’ll be your personal shopping buddy.")
                .font(.buydeeLargeTitle)
                .foregroundStyle(Color(red: 82 / 255, green: 54 / 255, blue: 2 / 255))

            ZStack {
                Image("otter")

                Ellipse()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 700, height: 450)
                    .offset(x: 0, y: 400)
            }

            Button(action: action) {
                Text("Bring me along")
                    .font(.buydeeHeadline)
                    .foregroundStyle(.white)
                    .frame(width:250, height: 48)
                    .background(Color(red: 84/255, green: 88/255, blue: 26/255))
                    .clipShape(
                        RoundedRectangle(cornerRadius: BuydeeRadius.small)
                    )
            }
            .padding(.horizontal, 50)
            .padding(.bottom, 40)
        }
        
    }
}

#Preview {
    OnboardingPage1View(action: {})
}
