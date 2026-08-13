//
//  OnboardingGoal.swift
//  buydee
//
import Foundation
enum OnboardingGoal: String, CaseIterable, Identifiable {
    case holiday = "Holiday fund"
    case invest = "Invest it"
    case savings = "My savings"
    case others = "Others"
    var id: String { self.rawValue }
    var iconName: String {
        switch self {
        case .holiday: return "holiday-fund"
        case .invest: return "invest-it"
        case .savings: return "my-savings"
        case .others: return "square.and.pencil"
        }
    }
    var isSystemIcon: Bool {
        switch self {
        case .others: return true
        default: return false
        }
    }
}
