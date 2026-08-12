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
            ZStack {
                background(in: geometry)

                SavingsSummaryView(
                    savedAmount: viewModel.formattedSavedAmount,
                    goalMessage: viewModel.goalMessage,
                    isGoalMessageLoading: viewModel.isGoalMessageLoading,
                    canRetryGoalMessage: viewModel.canRetryGoalMessage,
                    retryGoalMessageAction: viewModel.retryGoalMessage,
                    editGoalAction: presentEditGoal
                )
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height * 0.20
                )

                Image("otter")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 229, height: 225)
                    .accessibilityLabel("Buydee otter mascot")
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height * 0.5
                    )

                VStack(spacing: 20) {
                    Text("Feeling like buying something?")
                        .font(.buydeeTitle3)
                        .foregroundStyle(Color.buydee.primaryText)
                        .multilineTextAlignment(.center)

                    NewCheckButton(action: newCheckAction)
                        .frame(width: min(238, geometry.size.width - 64))
                }
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height * 0.73
                )
            }
        }
        .background(Color.buydee.canvasBackground)
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
    private func background(in geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            Color.buydee.canvasBackground
                .frame(height: geometry.size.height * 0.55)

            Color.buydee.background
        }
        .ignoresSafeArea()
    }

    private func presentEditGoal() {
        isEditGoalPresented = true
        editGoalAction()
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}
