//
//  CameraService.swift
//  buydee
//

@preconcurrency import AVFoundation
import UIKit

enum CameraServiceError: LocalizedError {
    case cameraUnavailable
    case configurationFailed
    case captureFailed
    case torchUnavailable

    var errorDescription: String? {
        switch self {
        case .cameraUnavailable:
            return "Camera is not available on this device."
        case .configurationFailed:
            return "Buydee could not prepare the camera."
        case .captureFailed:
            return "The photo could not be captured. Please try again."
        case .torchUnavailable:
            return "Flash is not available on this device."
        }
    }
}

final class CameraService: NSObject {
    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "com.buydee.camera.session")
    private let photoOutput = AVCapturePhotoOutput()
    private var captureCompletion: ((Result<UIImage, Error>) -> Void)?
    private var isConfigured = false
    private var cameraHasFlash = false
    private var cameraDevice: AVCaptureDevice?

    func configure(completion: @escaping (Result<Void, Error>) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            if self.isConfigured {
                DispatchQueue.main.async { completion(.success(())) }
                return
            }

            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            defer {
                self.session.commitConfiguration()
            }

            guard let camera = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back
            ) else {
                DispatchQueue.main.async {
                    completion(.failure(CameraServiceError.cameraUnavailable))
                }
                return
            }

            do {
                let input = try AVCaptureDeviceInput(device: camera)

                guard self.session.canAddInput(input), self.session.canAddOutput(self.photoOutput) else {
                    DispatchQueue.main.async {
                        completion(.failure(CameraServiceError.configurationFailed))
                    }
                    return
                }

                self.session.addInput(input)
                self.session.addOutput(self.photoOutput)
                self.cameraDevice = camera
                self.cameraHasFlash = camera.hasFlash
                self.isConfigured = true

                DispatchQueue.main.async { completion(.success(())) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    func start() {
        sessionQueue.async { [weak self] in
            guard let self, self.isConfigured, !self.session.isRunning else { return }
            self.session.startRunning()
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.turnTorchOffIfNeeded()

            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    func setTorch(
        enabled: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        sessionQueue.async { [weak self] in
            guard let self,
                  let cameraDevice = self.cameraDevice,
                  cameraDevice.hasTorch else {
                DispatchQueue.main.async {
                    completion(.failure(CameraServiceError.torchUnavailable))
                }
                return
            }

            do {
                try cameraDevice.lockForConfiguration()
                defer { cameraDevice.unlockForConfiguration() }

                if enabled {
                    try cameraDevice.setTorchModeOn(level: 1)
                } else {
                    cameraDevice.torchMode = .off
                }

                DispatchQueue.main.async { completion(.success(())) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    func capturePhoto(
        flashEnabled: Bool,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        captureCompletion = completion

        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashEnabled && cameraHasFlash ? .on : .off
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    private func turnTorchOffIfNeeded() {
        guard let cameraDevice,
              cameraDevice.hasTorch,
              cameraDevice.torchMode != .off else { return }

        do {
            try cameraDevice.lockForConfiguration()
            defer { cameraDevice.unlockForConfiguration() }
            cameraDevice.torchMode = .off
        } catch {
            // The session can still be stopped safely if the torch cannot be changed.
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            captureCompletion?(.failure(error))
            captureCompletion = nil
            return
        }

        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else {
            captureCompletion?(.failure(CameraServiceError.captureFailed))
            captureCompletion = nil
            return
        }

        captureCompletion?(.success(image))
        captureCompletion = nil
    }
}
