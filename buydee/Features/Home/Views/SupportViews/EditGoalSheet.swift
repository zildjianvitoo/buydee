//
//  EditGoalSheet.swift
//  buydee
//

import SwiftUI

struct EditGoalSheet: View {
    // MARK: - Properties
    @Environment(\.dismiss) private var dismiss
    @State private var goalText: String

    let saveAction: (String) -> Void

    // MARK: - Initialization
    init(goalText: String, saveAction: @escaping (String) -> Void) {
        _goalText = State(initialValue: goalText)
        self.saveAction = saveAction
    }

    // MARK: - Computed Properties
    private var isGoalEmpty: Bool {
        goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()

                Capsule()
                    .fill(Color.secondary.opacity(0.35))
                    .frame(width: 36, height: 5)

                Spacer()
            }
            .padding(.bottom, 10)

            header
                .padding(.bottom, 28)

            Text("What would you like to keep in mind\nbefore you buy?")
                .font(.buydeeHeadline)
                .foregroundStyle(Color.buydee.primaryText)
                .fontWeight(.semibold)

            Text("This data will be used to personalize the app.")
                .font(.buydeeSubheadline)
                .foregroundStyle(Color.buydee.primaryText)
                .padding(.top, 8)
                .fontWeight(.regular)

            TextField("Enter your goal", text: $goalText)
                .font(.buydeeFootnote)
                .foregroundStyle(Color.buydee.primaryText)
                .padding(.horizontal, 17)
                .padding(.vertical, 16)
                .background(Color.buydee.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: BuydeeRadius.small))
                .padding(.top, 30)
                .submitLabel(.done)
                .onSubmit(saveGoal)

            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.top, 18)
    }

    // MARK: - Subviews
    private var header: some View {
        HStack {
            Text("Goals")
                .font(.buydeeTitle2)
                .foregroundStyle(Color.buydee.primaryText)

            Spacer()

            Button(action: saveGoal) {
                Image(systemName: "checkmark")
                    .font(.buydeeTitle3)
                    .foregroundStyle(Color.buydee.primaryText)
                    .frame(width: 52, height: 52)
                    .background(Color.black.opacity(0.05))
                    .clipShape(Circle())
            }
            .disabled(isGoalEmpty)
            .opacity(isGoalEmpty ? 0.4 : 1)
            .accessibilityLabel("Save goal")
        }
    }

    // MARK: - Methods
    private func saveGoal() {
        guard !isGoalEmpty else { return }
        saveAction(goalText)
        dismiss()
    }
}

#Preview {
    Color.gray
        .sheet(isPresented: .constant(true)) {
            EditGoalSheet(goalText: "I want to go to Singapore") { _ in }
                .presentationDetents([.fraction(0.46)])
                .presentationDragIndicator(.visible)
        }
}
