//
//  HomeViewModel.swift
//  buydee
//

import Foundation
import SwiftUI

@Observable
final class HomeViewModel {
    // MARK: - Properties
    var savedAmount: Int
    var goalDescription: String?

    private let userDefaults: UserDefaults
    private static let goalDescriptionKey = "goalDescription"

    // MARK: - Initialization
    init(
        savedAmount: Int = 0,
        goalDescription: String? = nil,
        userDefaults: UserDefaults = .standard
    ) {
        self.savedAmount = savedAmount
        self.userDefaults = userDefaults
        self.goalDescription = goalDescription
            ?? userDefaults.string(forKey: Self.goalDescriptionKey)
    }

    // MARK: - Computed Properties
    var formattedSavedAmount: String {
        let amount = savedAmount.formatted(
            .number
                .grouping(.automatic)
                .locale(Locale(identifier: "id_ID"))
        )

        return "\(amount)"
    }

    var goalMessage: String {
        goalDescription ?? "Convert goals will be shown here."
    }

    // MARK: - Methods
    func saveGoal(_ goal: String) {
        let trimmedGoal = goal.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedGoal.isEmpty else { return }

        goalDescription = trimmedGoal
        userDefaults.set(trimmedGoal, forKey: Self.goalDescriptionKey)
    }
}
