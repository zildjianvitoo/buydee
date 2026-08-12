//
//  OnboardingView.swift
//  buydee
//
import SwiftUI
struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            
            
            OnboardingPage1View(action: {
                viewModel.nextPage()
            })
            .tag(0)
            
//            OnboardingPage2View(action: {
//                viewModel.nextPage()
//            })
//            .tag(1)
            
            OnboardingPage3View(action: {
                viewModel.nextPage()
            })
            .tag(1)
        
            OnboardingPage4View(viewModel: viewModel, action: {
                viewModel.completeOnboarding()
            })
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut, value: viewModel.currentPage)
        .ignoresSafeArea()
    }
}
#Preview {
    OnboardingView()
}
