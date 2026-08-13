//
//  HomeView.swift
//  buydee
//

import SwiftUI

struct HomeView: View {
    // MARK: - Properties
    @State private var viewModel: HomeViewModel
    @State private var isEditGoalPresented = false

    private let editGoalAction: () -> Void
    private let newCheckAction: () -> Void

    // MARK: - Initialization
    init(
        viewModel: HomeViewModel,
        editGoalAction: @escaping () -> Void = {},
        newCheckAction: @escaping () -> Void = {}
    ) {
        _viewModel = State(initialValue: viewModel)
        self.editGoalAction = editGoalAction
        self.newCheckAction = newCheckAction
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                SavingsSummaryView(
                    savedAmount: viewModel.formattedSavedAmount,
                    goalMessage: viewModel.goalMessage,
                    isGoalMessageLoading: viewModel.isGoalMessageLoading,
                    canRetryGoalMessage: viewModel.canRetryGoalMessage,
                    retryGoalMessageAction: viewModel.retryGoalMessage,
                    editGoalAction: presentEditGoal
                )
                .padding(.top, geometry.size.height * 0.08)

                Spacer(minLength: 24)

                VStack(spacing: 20) {
                    Text("Feeling like buying something?")
                        .font(.buydeeTitle3)
                        .foregroundStyle(Color.buydee.primaryText)
                        .multilineTextAlignment(.center)

                    NewCheckButton(action: newCheckAction)
                        .frame(width: min(238, geometry.size.width - 64))
                }
                .padding(.bottom, geometry.size.height * 0.18)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background {
            Image("BGHome")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .background(Color.buydee.canvasBackground.ignoresSafeArea())
        .sheet(isPresented: $isEditGoalPresented) {
            EditGoalSheet(
                goalText: viewModel.goalDescription ?? "",
                saveAction: viewModel.saveGoal
            )
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: BuydeeRadius.medium, style: .continuous)
            )
            .padding(.horizontal, 4)
            .padding(.bottom, 16)
            .presentationDetents([.fraction(0.46)])
            .presentationDragIndicator(.hidden)
            .presentationBackground(.clear)
        }
    }

    // MARK: - Private Methods
    private func presentEditGoal() {
        isEditGoalPresented = true
        editGoalAction()
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}
