//
//  OnboardingPage3View.swift
//  buydee
//
import SwiftUI
struct OnboardingPage3View: View {
    // MARK: - Properties
    var action: () -> Void
    @State private var carouselIndex = 0

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("So, here's how\nwe'll do it.")
                .font(.buydeeLargeTitle)
                .foregroundStyle(Color.buydee.primaryText)
                .padding(.top, 40)
            Text("However you find it, bring it here and we'll think it through with what matters to you in mind.")
                .font(.buydeeBody)
                .foregroundStyle(Color.buydee.primaryText)
                .padding(.trailing, 20)
            Spacer()
            
            VStack(spacing: 32) {
                TabView(selection: $carouselIndex) {
                    ForEach(0..<3, id: \.self) { index in
                        RoundedRectangle(cornerRadius: BuydeeRadius.medium)
                            .fill(Color.buydee.background)
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .padding(.horizontal, 8)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 300)
                
                // Custom Page Indicators
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(carouselIndex == index ? Color.buydee.primaryButton : Color.buydee.background)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            
            Spacer()
            Button(action: action) {
                Text("Got it")
                    .font(.buydeeHeadline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.buydee.primaryButton)
                    .clipShape(RoundedRectangle(cornerRadius: BuydeeRadius.small))
            }
            .padding(.bottom, 48)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.buydee.canvasBackground)
    }
}
#Preview {
    OnboardingPage3View(action: {})
}
