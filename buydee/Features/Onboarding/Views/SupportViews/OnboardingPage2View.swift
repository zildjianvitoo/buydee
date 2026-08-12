//
//  OnboardingPage2View.swift
//  buydee
//
//  Created by Muhammad Muttakin on 11/08/26.
//

import SwiftUI

struct OnboardingPage2View: View {
    var action: () -> Void
    var body: some View {
        VStack {
            Text("Let's take another look before you buy!")
                .font(.largeTitle.bold())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 24)
                .foregroundStyle(Color(red: 82 / 255, green: 54 / 255, blue: 2 / 255))

            Text("I’ll be here whenever you’re thinking\nabout buying something!")
                .font(.title3)
                .padding(.top, 2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(Color(red: 82 / 255, green: 54 / 255, blue: 2 / 255))
        
            ZStack {
                VStack(spacing: 3) {
                    iconCircle(icon: "hat.widebrim.fill")

                    HStack {
                        iconCircle(icon: "bag.fill")

                        Spacer()

                        iconCircle(icon: "sunglasses")
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 150)
                // MARK: - Otter

                Image("otter")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .offset(y: 100)
            }
            .frame(height: 450)
            
            Spacer()

            Button(action: action) {
                Text("Show Me")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width:250, height: 48)
                    .background(Color(Color(red: 84/255, green: 88/255, blue: 26/255)))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
            }
            .padding(.horizontal, 50)
            .padding(.bottom, 40)
        }
        .padding(.horizontal, 30)
    }


    func iconCircle(icon: String) -> some View {
        ZStack {
            Circle()
                .fill(Color(red: 212 / 255, green: 219 / 255, blue: 129 / 255 ))
                .frame(width: 76, height: 76)

            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(Color(red: 82 / 255, green: 54 / 255, blue: 2 / 255))
        }
    }
}

#Preview {
    OnboardingPage2View(action: {})
}
