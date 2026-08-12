//
//  SavingsSummaryView.swift
//  buydee
//

import SwiftUI

struct SavingsSummaryView: View {
    // MARK: - Properties
    let savedAmount: String
    let goalMessage: String
    let editGoalAction: () -> Void

    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            Text("You Saved")
                .font(.buydeeHeadline)
                .foregroundStyle(Color.buydee.secondaryText)

            HStack(alignment: .top, spacing: 4) {
                Text("Rp")
                    .font(.buydeeTitle2)
                
                Text(savedAmount)
                    .font(.buydeeLargeTitle)
                    .foregroundStyle(Color.buydee.primaryText)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }

            VStack(alignment: .center, spacing: 4) {
                Text(goalMessage)
                   .font(.buydeeBody)
                   .foregroundStyle(Color.buydee.primaryText)
                   .multilineTextAlignment(.center)

               Button("Edit your goals here.", action: editGoalAction)
                   .font(.buydeeSubheadline)
                   .foregroundStyle(Color.buydee.linkText)
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
