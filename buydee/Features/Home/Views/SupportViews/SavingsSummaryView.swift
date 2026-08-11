//
//  SavingsSummaryView.swift
//  buydee
//

import SwiftUI

struct SavingsSummaryView: View {
    let savedAmount: String
    let goalMessage: String
    let editGoalAction: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text("You Saved")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.buydee.secondaryText)

            HStack(alignment: .top, spacing: 4) {
                Text("Rp")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(savedAmount)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.buydee.primaryText)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }

            VStack(alignment: .center, spacing: 4) {
                Text(goalMessage)
                   .font(.headline)
                   .fontWeight(.regular)
                   .foregroundStyle(Color.buydee.primaryText)
                   .multilineTextAlignment(.center)

               Button("Edit your goals here.", action: editGoalAction)
                   .font(.subheadline)
                   .foregroundStyle(Color(hex: "#1E2691"))
                   .accessibilityHint("Opens your savings goal settings")
                   .underline()
            }
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    SavingsSummaryView(
        savedAmount: "0",
        goalMessage: "Convert goals will be shown here.",
        editGoalAction: {}
    )
}
