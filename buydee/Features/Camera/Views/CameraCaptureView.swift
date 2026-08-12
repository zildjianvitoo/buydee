//
//  CameraCaptureView.swift
//  buydee
//

import PhotosUI
import SwiftUI

struct CameraCaptureView: View {
    // MARK: - Properties
    @Environment(\.openURL) private var openURL
    @State private var viewModel = CameraCaptureViewModel()

    let onDismiss: () -> Void
    let onImageCaptured: (UIImage) -> Void
    
    // MARK: - Initialization
    init(
        onDismiss: @escaping () -> Void,
        onImageCaptured: @escaping (UIImage) -> Void = { _ in }
    ) {
        self.onDismiss = onDismiss
        self.onImageCaptured = onImageCaptured
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                cameraBackground(in: proxy)

                if viewModel.showsGuide && viewModel.capturedImage == nil {
                    Color.black.opacity(0.68)
                        .ignoresSafeArea()
                        .transition(.opacity)
                }

                if let capturedImage = viewModel.capturedImage {
                    capturedPhotoControls(image: capturedImage, in: proxy)
                } else {
                    liveCameraControls(in: proxy)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .clipped()
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
        .ignoresSafeArea()
        .task {
            viewModel.startCamera()
        }
        .onDisappear {
            viewModel.stopCamera()
        }
        .alert("Flash Unavailable", isPresented: showsFlashError) {
            Button("OK", role: .cancel, action: viewModel.dismissFlashError)
        } message: {
            Text(viewModel.flashErrorMessage ?? "")
        }
    }
    
    // MARK: - Support Views
    @ViewBuilder
    private func cameraBackground(in proxy: GeometryProxy) -> some View {
        if let capturedImage = viewModel.capturedImage {
            Image(uiImage: capturedImage)
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()
                .accessibilityLabel("Captured item photo")
        } else {
            switch viewModel.status {
            case .ready, .loading:
                CameraPreview(session: viewModel.session)
                    .ignoresSafeArea()
                    .overlay {
                        if viewModel.status == .loading {
                            ProgressView("Preparing camera…")
                                .tint(.white)
                                .foregroundStyle(.white)
                        }
                    }
            case .permissionDenied:
                cameraUnavailableView(
                    title: "Camera Access Needed",
                    message: "Allow camera access in Settings to photograph an item.",
                    showsSettingsButton: true
                )
            case .unavailable(let message):
                cameraUnavailableView(
                    title: "Camera Unavailable",
                    message: message,
                    showsSettingsButton: false
                )
            }
        }
    }

    private func liveCameraControls(in proxy: GeometryProxy) -> some View {
        ZStack {
            VStack(spacing: 0) {
                topControls
                    .padding(.top, proxy.safeAreaInsets.top + 60)

                Spacer()

                bottomControls
                    .allowsHitTesting(!viewModel.showsGuide)
                    .accessibilityHidden(viewModel.showsGuide)
                    .padding(.bottom, max(proxy.safeAreaInsets.bottom + 10, 44))
            }

            if viewModel.showsGuide {
                CameraGuideCard(action: viewModel.dismissGuide)
                    .frame(maxHeight: proxy.size.height * 0.48)
                    .padding(.horizontal, 24)
                    .transition(.scale(scale: 0.96).combined(with: .opacity))
            }
        }
    }

    private var topControls: some View {
        HStack {
            overlayButton(
                systemImage: "xmark",
                label: "Close camera",
                hitTargetSize: 48,
                action: onDismiss
            )

            Spacer()

            overlayButton(
                systemImage: "questionmark.circle.fill",
                label: "Show camera guide",
                iconSize: 22,
                hitTargetSize: 48,
                action: viewModel.showGuide
            )
        }
        .padding(.horizontal, 20)
    }

    private var bottomControls: some View {
        VStack(spacing: 16) {
            cameraTip

            HStack {
                PhotosPicker(
                    selection: $viewModel.selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    cameraControlLabel(systemImage: "photo.fill")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Choose a photo")

                Spacer()

                Button(action: viewModel.capturePhoto) {
                    ZStack {
                        Circle()
                            .fill(.clear)
                            .glassEffect(
                                .clear
                                    .tint(.white.opacity(0.10))
                                    .interactive(),
                                in: Circle()
                            )
                            .overlay {
                                Circle()
                                    .stroke(.white.opacity(0.38), lineWidth: 1)
                            }

                        Circle()
                            .fill(.white)
                            .frame(width: 68, height: 68)
                            .shadow(color: .black.opacity(0.10), radius: 1, y: 1)
                    }
                    .frame(width: 80, height: 80)
                    .contentShape(Circle())
                }
                .buttonStyle(IOS26CameraShutterButtonStyle())
                .disabled(viewModel.status != .ready || viewModel.isCapturing || viewModel.showsGuide)
                .accessibilityLabel("Take photo")
                .accessibilityHint("Captures the item in the frame")

                Spacer()

                overlayButton(
                    systemImage: "bolt.fill",
                    label: viewModel.isFlashEnabled ? "Turn flash off" : "Turn flash on",
                    foregroundColor: viewModel.isFlashEnabled ? .yellow : Color(uiColor: .darkGray),
                    action: viewModel.toggleFlash
                )
            }
            .padding(.horizontal, 62)
        }
    }

    private var cameraTip: some View {
        VStack(spacing: -5) {
            HStack(spacing: 4) {
                Text("Tips")
                Image(systemName: "lightbulb.fill")
                    .imageScale(.small)
            }
            .font(.caption)
            .foregroundStyle(.white)
            .frame(width: 68, height: 24)
            .background {
                RoundedRectangle(cornerRadius: 21, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(0.28)
                    .overlay {
                        RoundedRectangle(cornerRadius: 21, style: .continuous)
                            .fill(cameraTipTint.opacity(0.70))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 21, style: .continuous)
                    .stroke(.white.opacity(0.58), lineWidth: 1)
            }
            .shadow(color: cameraTipTint.opacity(0.12), radius: 5, y: 1)
            .zIndex(1)

            Text("Keep the item clearly visible in the frame.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(width: 260, height: 37)
                .background(
                    Color.black.opacity(0.58),
                    in: RoundedRectangle(cornerRadius: 14, style: .circular)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .circular)
                        .stroke(.white.opacity(0.55), lineWidth: 1)
                }
        }
        .accessibilityElement(children: .combine)
    }

    private var cameraTipTint: Color {
        Color(
            red: 212.0 / 255.0,
            green: 219.0 / 255.0,
            blue: 129.0 / 255.0
        )
    }

    private func capturedPhotoControls(image: UIImage, in proxy: GeometryProxy) -> some View {
        VStack {
            HStack {
                if viewModel.capturedImageSource == .photoLibrary {
                    overlayButton(
                        systemImage: "arrow.left",
                        label: "Back to camera",
                        hitTargetSize: 48,
                        action: viewModel.retakePhoto
                    )
                } else {
                    overlayButton(
                        systemImage: "xmark",
                        label: "Close preview",
                        hitTargetSize: 48,
                        action: onDismiss
                    )
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)

            Spacer()

            if viewModel.capturedImageSource == .photoLibrary {
                Button {
                    usePhoto(image)
                } label: {
                    Label("Use Photo", systemImage: "checkmark")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(Color.buydee.primaryButton)
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
            } else {
                HStack(spacing: 16) {
                    Button("Retake", systemImage: "arrow.counterclockwise", action: viewModel.retakePhoto)
                        .buttonStyle(.bordered)
                        .controlSize(.large)

                    Button("Use Photo", systemImage: "checkmark") {
                        usePhoto(image)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(Color.buydee.primaryButton)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
            }
        }
        .frame(width: proxy.size.width, height: proxy.size.height)
        .foregroundStyle(.white)
    }
    
    // MARK: - Private Methods
    private func usePhoto(_ image: UIImage) {
        onImageCaptured(image)
        onDismiss()
    }

    private func overlayButton(
        systemImage: String,
        label: String,
        iconSize: CGFloat = 19,
        foregroundColor: Color = Color(uiColor: .darkGray),
        hitTargetSize: CGFloat = 40,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            cameraControlLabel(
                systemImage: systemImage,
                iconSize: iconSize,
                foregroundColor: foregroundColor
            )
            .frame(width: hitTargetSize, height: hitTargetSize)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func cameraControlLabel(
        systemImage: String,
        iconSize: CGFloat = 19, // Retained for backward compatibility in function signature, but overridden by Dynamic Type
        foregroundColor: Color = Color(uiColor: .darkGray)
    ) -> some View {
        ZStack {
            Circle()
                .fill(.white)

            Image(systemName: systemImage)
                .font(.headline) // Fixed: Using Dynamic Type instead of hardcoded .system(size:)
                .foregroundStyle(foregroundColor)
        }
        .frame(width: 40, height: 40)
    }

    private var showsFlashError: Binding<Bool> {
        Binding(
            get: { viewModel.flashErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.dismissFlashError()
                }
            }
        )
    }

    private func cameraUnavailableView(
        title: String,
        message: String,
        showsSettingsButton: Bool
    ) -> some View {
        ContentUnavailableView {
            Label(title, systemImage: "camera.fill")
        } description: {
            Text(message)
        } actions: {
            if showsSettingsButton {
                Button("Open Settings") {
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                    openURL(settingsURL)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .foregroundStyle(.white)
        .padding()
    }
}

private struct IOS26CameraShutterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.smooth(duration: 0.16), value: configuration.isPressed)
    }
}

#Preview("Guide") {
    CameraCaptureView(onDismiss: {})
}
