//
//  OnboardingView.swift
//  buydee
//

import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    
    var body: some View {
        TabView(selection: $viewModel.currentPage) {
            
            // Placeholder for Page 1
            OnboardingPage1View(action: {
                viewModel.nextPage()
            })
            .tag(0)
            
            // Placeholder for Page 2
            OnboardingPage2View(action: {
                viewModel.nextPage()
            })
            .tag(1)
            
            // Page 3
            OnboardingPage3View(action: {
                viewModel.nextPage()
            })
            .tag(2)
            
            // Page 4
            OnboardingPage4View(viewModel: viewModel, action: {
                viewModel.completeOnboarding()
            })
            .tag(3)
            
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut, value: viewModel.currentPage)
        .ignoresSafeArea()
    }
}

#Preview {
    OnboardingView()
}
