//
//  OnboardingViewModel.swift
//  buydee
//

import SwiftUI
import UserNotifications

@Observable
class OnboardingViewModel {
    var currentPage: Int = 0
    let totalPages: Int = 4 // Pages 1 and 2 are placeholders, 3 and 4 are implemented
    
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
        selectedGoal = goal
        if goal != .others {
            customGoalText = ""
        }
    }
    
    func completeOnboarding() {
        // Request notification permission before finishing
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                // Save onboarding state regardless of permission granted or not
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            }
        }
    }
}
