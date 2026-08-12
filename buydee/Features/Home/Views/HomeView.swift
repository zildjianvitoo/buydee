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
        viewModel: HomeViewModel = HomeViewModel(),
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
                    editGoalAction: presentEditGoal
                )
                .position(
                    x: geometry.size.width / 2,
                    y: geometry.size.height * 0.20
                )

                Image("OtterImg")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 180)
                    .accessibilityLabel("Buydee otter mascot")
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height * 0.53
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
        .background(Color.buydee.cardBackground)
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
            Color.buydee.cardBackground
                .frame(height: geometry.size.height * 0.55)

            Color.buydee.secondaryBackground
        }
        .ignoresSafeArea()
    }

    private func presentEditGoal() {
        isEditGoalPresented = true
        editGoalAction()
    }
}

#Preview {
    HomeView()
}
