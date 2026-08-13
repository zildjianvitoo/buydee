//
//  OnboardingView.swift
//  buydee
//
import SwiftUI
struct OnboardingView: View {
    @State private var viewModel = OnboardingViewModel()

    var body: some View {
        ZStack {
            Color.buydee.canvasBackground
                .ignoresSafeArea()

            switch viewModel.currentPage {
            case 0:
            OnboardingPage1View(action: {
                viewModel.nextPage()
            })

            case 1:
            OnboardingPage3View(action: {
                viewModel.nextPage()
            })

            case 2:
            OnboardingPage4View(viewModel: viewModel, action: {
                viewModel.nextPage()
            })

            default:
            OnboardingPage5View(action: {
                viewModel.completeOnboarding()
            })
            }
        }
        .animation(.easeInOut, value: viewModel.currentPage)
    }
}
#Preview {
    OnboardingView()
}
