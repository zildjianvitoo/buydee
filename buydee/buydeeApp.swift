//
//  buydeeApp.swift
//  buydee
//
//  Created by Zildjian Vito  on 06/08/26.
//

import SwiftUI

@main
struct BuydeeApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView()
            }
        }
    }
}
