//
//  OnboardingView.swift
//  buydee
//

import SwiftUI

struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()
    
    var body: some View {
        ZStack {
            switch viewModel.currentPage {
            case 0:
            // Placeholder for Page 1
            VStack {
                Text("Page 1 (Placeholder)")
                    .font(.title) // Dynamic Type
                Button("Next") { viewModel.nextPage() }
                    .padding()
            }

            case 1:
            // Placeholder for Page 2
            VStack {
                Text("Page 2 (Placeholder)")
                    .font(.title) // Dynamic Type
                Button("Next") { viewModel.nextPage() }
                    .padding()
            }

            case 2:
            // Page 3
            OnboardingPage3View(action: {
                viewModel.nextPage()
            })

            default:
            // Page 4
            OnboardingPage4View(viewModel: viewModel, action: {
                viewModel.completeOnboarding()
            })
            }
        }
        .id(viewModel.currentPage)
        .transition(.opacity)
        .animation(.easeInOut, value: viewModel.currentPage)
        .ignoresSafeArea()
    }
}

#Preview {
    OnboardingView()
}
