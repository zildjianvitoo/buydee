//
//  SavingsSummaryView.swift
//  buydee
//

import SwiftUI

struct SavingsSummaryView: View {
    // MARK: - Properties
    let savedAmount: String
    let goalMessage: String
    let isGoalMessageLoading: Bool
    let canRetryGoalMessage: Bool
    let retryGoalMessageAction: () -> Void
    let editGoalAction: () -> Void

    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            Text("You Saved")
                .font(.buydeeHeadline)
                .foregroundStyle(Color.buydee.primaryText)

            HStack(alignment: .top, spacing: 4) {
                Text("Rp")
                    .font(.buydeeTitle2)
                    .foregroundStyle(Color.buydee.primaryText)
                
                Text(savedAmount)
                    .font(.buydeeLargeTitle)
                    .foregroundStyle(Color.buydee.primaryText)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }

            VStack(alignment: .center, spacing: 4) {
                if canRetryGoalMessage {
                    Button(action: retryGoalMessageAction) {
                        goalMessageText
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("Tries writing your goal message again")
                } else {
                    goalMessageText
                }

               Button("Edit your goals here.", action: editGoalAction)
                   .font(.buydeeSubheadline)
                   .foregroundStyle(Color.buydee.primaryButton)
                   .accessibilityHint("Opens your savings goal settings")
            }
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Subviews
    private var goalMessageText: some View {
        Text(goalMessage)
            .font(.buydeeBody)
            .foregroundStyle(Color.buydee.primaryText)
            .multilineTextAlignment(.center)
            .redacted(reason: isGoalMessageLoading ? .placeholder : [])
    }
}

#Preview {
    SavingsSummaryView(
        savedAmount: "1.500.000",
        goalMessage: "That’s a round-trip ticket, four nights in Tokyo, and a week of local food tours.",
        isGoalMessageLoading: false,
        canRetryGoalMessage: false,
        retryGoalMessageAction: {},
        editGoalAction: {}
    )
}
