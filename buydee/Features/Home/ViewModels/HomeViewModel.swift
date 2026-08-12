//
//  HomeViewModel.swift
//  buydee
//

import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class HomeViewModel {
    // MARK: - Properties
    var savedAmount: Int
    var goalDescription: String?
    private var isGeneratingGoalMessage = false
    private var goalMessageFailed = false
    private var motivationMessage: String?

    @ObservationIgnored private let service: any GoalMessageGenerating
    @ObservationIgnored private let userDefaults: UserDefaults
    @ObservationIgnored private var cachedGoalMessage: GoalMessageCache?
    @ObservationIgnored private var goalMessageTask: Task<Void, Never>?
    @ObservationIgnored private var pendingRequest: GoalMessageRequest?

    private static let savedAmountKey = "totalSavedAmount"
    private static let goalDescriptionKey = "goalDescription"
    private static let onboardingGoalsKey = "userGoals"
    private static let goalMessageCacheKey = "goalMotivationMessage"
    private static let placeholderGoalMessage = "Convert goals will be shown here."
    private static let failedGoalMessage = "Couldn’t convert your goal right now. Tap to try again."

    // MARK: - Initialization
    init(
        savedAmount: Int? = nil,
        goalDescription: String? = nil,
        service: (any GoalMessageGenerating)? = nil,
        userDefaults: UserDefaults = .standard
    ) {
        self.service = service ?? OpenRouterGoalMessageService()
        self.userDefaults = userDefaults
        self.savedAmount = savedAmount ?? userDefaults.integer(forKey: Self.savedAmountKey)
        self.goalDescription = goalDescription
            ?? userDefaults.string(forKey: Self.goalDescriptionKey)
            ?? userDefaults.string(forKey: Self.onboardingGoalsKey)

        cachedGoalMessage = Self.loadCache(from: userDefaults)
        motivationMessage = cachedGoalMessage?.message
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
        if let motivationMessage, !motivationMessage.isEmpty {
            return motivationMessage
        }
        return goalMessageFailed ? Self.failedGoalMessage : Self.placeholderGoalMessage
    }

    /// Only reports loading while there is no message worth showing yet.
    var isGoalMessageLoading: Bool {
        isGeneratingGoalMessage && (motivationMessage?.isEmpty ?? true)
    }

    var canRetryGoalMessage: Bool {
        goalMessageFailed && !isGeneratingGoalMessage
    }

    // MARK: - Methods
    func saveGoal(_ goal: String) {
        let trimmedGoal = goal.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedGoal.isEmpty else { return }

        goalDescription = trimmedGoal
        userDefaults.set(trimmedGoal, forKey: Self.goalDescriptionKey)
        refreshGoalMessage()
    }

    /// Adds the money kept from a postponed purchase to the running savings total.
    func addSavings(_ amount: Int) {
        guard amount > 0 else { return }

        savedAmount += amount
        userDefaults.set(savedAmount, forKey: Self.savedAmountKey)
        refreshGoalMessage()
    }

    func retryGoalMessage() {
        guard canRetryGoalMessage else { return }
        refreshGoalMessage()
    }

    // MARK: - Private Methods
    /// Called only when the saved amount or the goal actually changes, so opening
    /// the app reuses the stored sentence instead of spending another AI request.
    private func refreshGoalMessage() {
        guard let goal = resolvedGoal, savedAmount > 0 else {
            clearGoalMessage()
            return
        }

        let request = GoalMessageRequest(savedAmount: savedAmount, goal: goal)
        if let cachedGoalMessage, cachedGoalMessage.request == request {
            motivationMessage = cachedGoalMessage.message
            return
        }

        guard pendingRequest != request else { return }
        generateGoalMessage(for: request)
    }

    private var resolvedGoal: String? {
        guard let goalDescription else { return nil }
        let trimmedGoal = goalDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedGoal.isEmpty ? nil : trimmedGoal
    }

    private func generateGoalMessage(for request: GoalMessageRequest) {
        goalMessageTask?.cancel()
        pendingRequest = request
        goalMessageFailed = false
        isGeneratingGoalMessage = true
        goalMessageTask = Task { [weak self] in
            guard let self else { return }
            defer {
                if self.pendingRequest == request {
                    self.pendingRequest = nil
                    self.isGeneratingGoalMessage = false
                }
            }

            do {
                let message = try await self.service.goalMessage(
                    savedAmount: request.savedAmount,
                    goal: request.goal
                )
                try Task.checkCancellation()
                self.storeGoalMessage(GoalMessageCache(request: request, message: message))
            } catch is CancellationError {
                return
            } catch {
                // Any message already on screen stays until the user retries.
                self.goalMessageFailed = true
            }
        }
    }

    private func storeGoalMessage(_ cache: GoalMessageCache) {
        cachedGoalMessage = cache
        motivationMessage = cache.message
        goalMessageFailed = false

        guard let data = try? JSONEncoder().encode(cache) else { return }
        userDefaults.set(data, forKey: Self.goalMessageCacheKey)
    }

    private func clearGoalMessage() {
        goalMessageTask?.cancel()
        goalMessageTask = nil
        pendingRequest = nil
        goalMessageFailed = false
        isGeneratingGoalMessage = false
        cachedGoalMessage = nil
        motivationMessage = nil
        userDefaults.removeObject(forKey: Self.goalMessageCacheKey)
    }

    private static func loadCache(from userDefaults: UserDefaults) -> GoalMessageCache? {
        guard let data = userDefaults.data(forKey: goalMessageCacheKey) else { return nil }
        return try? JSONDecoder().decode(GoalMessageCache.self, from: data)
    }
}

// MARK: - Supporting Types
private struct GoalMessageRequest: Codable, Equatable {
    let savedAmount: Int
    let goal: String
}

private struct GoalMessageCache: Codable {
    let request: GoalMessageRequest
    let message: String
}
