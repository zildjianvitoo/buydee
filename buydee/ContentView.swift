//
//  ContentView.swift
//  buydee
//
//  Created by Zildjian Vito  on 06/08/26.
//
import SwiftUI
struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var showsCamera = false
    @State private var lastCapturedImage: UIImage?

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let lastCapturedImage {
                    Image(uiImage: lastCapturedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: BuydeeRadius.medium, style: .continuous))
                        .accessibilityLabel("Last captured item")
                } else {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 56))
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)
                }

                Text("Check an item before you buy")
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)

                Button("Open Camera", systemImage: "camera.fill") {
                    showsCamera = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button("Reset Onboarding (Dev Only)") {
                    hasCompletedOnboarding = false
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .navigationTitle("Buydee")
        }
        .fullScreenCover(isPresented: $showsCamera) {
            CameraCaptureView(
                onDismiss: { showsCamera = false },
                onImageCaptured: { lastCapturedImage = $0 }
            )
        }
    }
}
#Preview {
    ContentView()
}
