//
//  OnboardingViewModel.swift
//  buydee
//
import SwiftUI
import UserNotifications
@Observable
@MainActor
final class OnboardingViewModel {
    var currentPage: Int = 0
    let totalPages: Int = 4
    var selectedGoal: OnboardingGoal? = nil
    var customGoalText: String = ""
    func nextPage() {
        if currentPage < totalPages - 1 {
            withAnimation {
                currentPage += 1
            }
        }
    }
    func selectGoal(_ goal: OnboardingGoal) {
        if selectedGoal == goal {
            // Jika ditap lagi saat sudah terbuka, tutup (deselect)
            selectedGoal = nil
        } else {
            // Pilih goal baru dan reset text field
            selectedGoal = goal
            if goal != .others {
                customGoalText = ""
            }
        }
    }
    func completeOnboarding() {
        let goals = if selectedGoal == .others {
            customGoalText.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            selectedGoal?.rawValue ?? ""
        }

        UserDefaults.standard.set(goals, forKey: "userGoals")

        Task {
            _ = try? await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }
    }
}
