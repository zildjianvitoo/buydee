//
//  OnboardingViewModel.swift
//  buydee
//
import SwiftUI

@Observable
@MainActor
final class OnboardingViewModel {
    var currentPage: Int = 0
    let totalPages: Int = 5
    var selectedGoal: OnboardingGoal? = nil
    var customGoalTexts: [OnboardingGoal: String] = [:]
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
            // Pilih goal baru
            selectedGoal = goal
        }
    }
    func completeOnboarding() {
        var goals = ""
        if let selected = selectedGoal {
            let typedText = customGoalTexts[selected]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if selected == .others {
                goals = typedText
            } else {
                goals = typedText.isEmpty ? selected.rawValue : typedText
            }
        }

        UserDefaults.standard.set(goals, forKey: "userGoals")

        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}
