//
//  OnboardingViewModel.swift
//  buydee
//
import SwiftUI
import UserNotifications
@Observable
class OnboardingViewModel {
    var currentPage: Int = 0
    let totalPages: Int = 5
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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            }
        }
    }
}
