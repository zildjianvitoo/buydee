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
        case .holiday: return "airplane"
        case .invest: return "dollarsign.circle.fill"
        case .savings: return "bag.fill"
        case .others: return "square.and.pencil"
        }
    }
}
