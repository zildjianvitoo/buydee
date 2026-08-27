//
//  CameraCaptureViewModel.swift
//  buydee
//

import AVFoundation
import Observation
import PhotosUI
import SwiftUI
import UIKit

@MainActor
@Observable
final class CameraCaptureViewModel {
    // MARK: - Enums
    enum CapturedImageSource: Equatable {
        case camera
        case photoLibrary
    }

    enum CameraStatus: Equatable {
        case loading
        case ready
        case permissionDenied
        case unavailable(message: String)
    }
    
    // MARK: - Properties
    var status: CameraStatus = .loading
    var capturedImage: UIImage?
    var capturedImageSource: CapturedImageSource?
    var isFlashEnabled = false
    var flashErrorMessage: String?
    var isCapturing = false
    var showsGuide: Bool
    var selectedPhotoItem: PhotosPickerItem? {
        didSet {
            guard let selectedPhotoItem else { return }
            loadPhoto(from: selectedPhotoItem)
        }
    }

    @ObservationIgnored private let cameraService: CameraService
    @ObservationIgnored private let userDefaults: UserDefaults
    @ObservationIgnored private let cameraGuideKey = "hasSeenCameraGuide"

    var session: AVCaptureSession {
        cameraService.session
    }
    
    // MARK: - Initialization
    init() {
        let userDefaults = UserDefaults.standard
        cameraService = CameraService()
        self.userDefaults = userDefaults
        showsGuide = !userDefaults.bool(forKey: cameraGuideKey)
    }
    
    // MARK: - Methods
    func startCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureCamera()
        case .notDetermined:
            Task {
                let isGranted = await AVCaptureDevice.requestAccess(for: .video)

                if isGranted {
                    configureCamera()
                } else {
                    status = .permissionDenied
                }
            }
        case .denied, .restricted:
            status = .permissionDenied
        @unknown default:
            status = .unavailable(message: "The camera cannot be accessed right now.")
        }
    }

    func stopCamera() {
        isFlashEnabled = false
        cameraService.stop()
    }

    func capturePhoto() {
        guard status == .ready, !isCapturing else { return }
        isCapturing = true

        cameraService.capturePhoto(flashEnabled: isFlashEnabled) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                self.isCapturing = false

                switch result {
                case .success(let image):
                    self.capturedImage = image
                    self.capturedImageSource = .camera
                    self.isFlashEnabled = false
                    self.cameraService.stop()
                case .failure(let error):
                    self.status = .unavailable(message: error.localizedDescription)
                }
            }
        }
    }

    func retakePhoto() {
        capturedImage = nil
        capturedImageSource = nil
        isFlashEnabled = false
        startCamera()
    }

    func toggleFlash() {
        guard status == .ready else { return }
        let shouldEnableFlash = !isFlashEnabled

        cameraService.setTorch(enabled: shouldEnableFlash) { [weak self] result in
            Task { @MainActor in
                guard let self else { return }

                switch result {
                case .success:
                    self.isFlashEnabled = shouldEnableFlash
                case .failure(let error):
                    self.flashErrorMessage = error.localizedDescription
                }
            }
        }
    }

    func dismissFlashError() {
        flashErrorMessage = nil
    }

    func dismissGuide() {
        userDefaults.set(true, forKey: cameraGuideKey)

        withAnimation(.easeOut(duration: 0.2)) {
            showsGuide = false
        }
    }

    func showGuide() {
        withAnimation(.easeIn(duration: 0.2)) {
            showsGuide = true
        }
    }

    private func configureCamera() {
        status = .loading

        cameraService.configure { [weak self] result in
            guard let self else { return }

            switch result {
            case .success:
                self.status = .ready
                self.cameraService.start()
            case .failure(let error):
                self.status = .unavailable(message: error.localizedDescription)
            }
        }
    }

    private func loadPhoto(from item: PhotosPickerItem) {
        Task {
            defer { selectedPhotoItem = nil }

            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                status = .unavailable(message: "The selected image could not be loaded.")
                return
            }

            capturedImage = image
            capturedImageSource = .photoLibrary
            isFlashEnabled = false
            cameraService.stop()
        }
    }
}
