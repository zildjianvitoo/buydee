//
//  SplashGateView.swift
//  buydee
//
//  Created by Fathariq Dimas on 13/08/26.
//

import SwiftUI

struct SplashGateView: View {
    @State private var isShowingSplash = true
    @Binding var hasCompletedOnboarding: Bool

    var body: some View {
        ZStack {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingView()
                }
            }
            .opacity(isShowingSplash ? 0 : 1)
            .allowsHitTesting(!isShowingSplash)

            if isShowingSplash {
                SplashScreenView()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
                    .zIndex(1)
            }
        }
        .task {
            try? await Task.sleep(for: .milliseconds(2_000))

            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.45)) {
                    isShowingSplash = false
                }
            }
        }
    }
}

private struct SplashScreenView: View {
    @State private var hasAppeared = false

    var body: some View {
        ZStack {
            Color.buydee.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                Image("img_splash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: 14,
                        x: 0,
                        y: 5
                    )
                    .scaleEffect(hasAppeared ? 1 : 0.78)
                
                VStack(spacing: 8) {
                    Text("Buydee")
                        .font(Font.buydeeTitle1)
                        .foregroundStyle(Color.buydee.primaryText)
                        .tracking(-1.5)

                    Text("Your thinking buddy before you buy.")
                        .font(Font.buydeeCallout.weight(.medium))
                        .foregroundStyle(Color.buydee.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .opacity(hasAppeared ? 1 : 0)
                .offset(y: hasAppeared ? 0 : 16)
                
                Spacer()
            }
            .padding(32)
        }
        .onAppear {
            withAnimation(.spring(response: 0.75, dampingFraction: 0.78)) {
                hasAppeared = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Buydee loading")
    }
}

#Preview {
    SplashScreenView()
}
