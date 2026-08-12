//
//  OnboardingPage3View.swift
//  buydee
//
import SwiftUI
struct OnboardingPage3View: View {
    // MARK: - Properties
    var action: () -> Void
    @State private var carouselIndex = 0
    
    private let carouselTitles = ["Capture it", "Share it", "Attach it"]
    private let carouselImages = ["onboarding-3-1", "onboarding-3-2", "onboarding-3-3"]

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("So, here's how\nwe'll do it.")
                .font(.buydeeLargeTitle)
                .foregroundStyle(Color.buydee.primaryText)
                .padding(.top, 40)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
            
            Text("However you find it, bring it here and we'll think it through with what matters to you in mind.")
                .font(.buydeeBody)
                .foregroundStyle(Color.buydee.primaryText)
                .padding(.trailing, 20)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
            Spacer()
            
            VStack(spacing: 20) {
                TabView(selection: $carouselIndex) {
                    ForEach(0..<3, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 16) {
                            Text(carouselTitles[index])
                                .font(.buydeeHeadline)
                                .foregroundStyle(Color.buydee.primaryText)
                            
                            Image(carouselImages[index])
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .padding(.horizontal, 4)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 320)
                
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
