//
//  EditGoalSheet.swift
//  buydee
//

import SwiftUI

struct EditGoalSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var goalText: String

    let saveAction: (String) -> Void

    init(goalText: String, saveAction: @escaping (String) -> Void) {
        _goalText = State(initialValue: goalText)
        self.saveAction = saveAction
    }

    private var isGoalEmpty: Bool {
        goalText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

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
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.buydee.primaryText)

            Text("This data will be used to personalize the app.")
                .font(.subheadline)
                .foregroundStyle(Color.buydee.secondaryText)
                .padding(.top, 8)

            TextField("Enter your goal", text: $goalText)
                .font(.footnote)
                .padding(.horizontal, 17)
                .padding(.vertical, 16)
                .background(Color.buydee.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.top, 30)
                .submitLabel(.done)
                .onSubmit(saveGoal)

            Spacer()
        }
        .padding(.horizontal, 32)
        .padding(.top, 18)
    }

    private var header: some View {
        HStack {
            Text("Goals")
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            Button(action: saveGoal) {
                Image(systemName: "checkmark")
                    .font(.title2)
                    .fontWeight(.semibold)
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
