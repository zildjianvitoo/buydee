//
//  buydeeApp.swift
//  buydee
//
//  Created by Zildjian Vito  on 06/08/26.
//
import SwiftUI
import SwiftData

@main
struct BuydeeApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            SplashGateView(hasCompletedOnboarding: $hasCompletedOnboarding)
        }
        .modelContainer(for: [UserChatKnowledge.self, PurchaseDecisionRecord.self])
    }
}
