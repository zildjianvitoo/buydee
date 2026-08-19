//
//  OnboardingPage3View.swift
//  buydee
//
import SwiftUI
struct OnboardingPage3View: View {
    // MARK: - Properties
    var action: () -> Void
    @State private var carouselIndex = 0
    
    struct OnboardingSlide {
        let title: String
        let description: String
        let image: String
    }
    
    private let slides: [OnboardingSlide] = [
        OnboardingSlide(
            title: "See it. Snap it.\nPause.",
            description: "Take a photo of the thing you're\ntempted to buy and bring it here.",
            image: "onboarding-3-1"
        ),
        OnboardingSlide(
            title: "Saved a\nscreenshot?",
            description: "Attach it here and we'll help you\ntake it from there.",
            image: "onboarding-3-3"
        )
    ]

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(spacing: 20) {
                TabView(selection: $carouselIndex) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 16) {
                            Text(slides[index].title)
                                .font(.buydeeLargeTitle)
                                .foregroundStyle(Color.buydee.primaryText)
                                .padding(.top, 36)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text(slides[index].description)
                                .font(.buydeeBody)
                                .foregroundStyle(Color.buydee.primaryText)
                                .padding(.trailing, 20)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.bottom, 16)
                            
                            Image(slides[index].image)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: BuydeeRadius.medium))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .padding(.horizontal, 4)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxHeight: .infinity)
                
                // Custom Page Indicators
                HStack(spacing: 8) {
                    ForEach(0..<slides.count, id: \.self) { index in
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
