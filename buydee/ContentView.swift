//
//  ContentView.swift
//  buydee
//
//  Created by Zildjian Vito  on 06/08/26.
//
import SwiftUI
struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "house.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Home View (Placeholder)")
                .font(.title)
            Button("Reset Onboarding (Dev Only)") {
                hasCompletedOnboarding = false
            }
            .padding(.top, 20)
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
#Preview {
    ContentView()
}
