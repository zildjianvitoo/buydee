//
//  CameraPreview.swift
//  buydee
//

import AVFoundation
import SwiftUI

struct CameraPreview: UIViewRepresentable {
    // MARK: - Properties
    let session: AVCaptureSession
    
    // MARK: - UIViewRepresentable
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.previewLayer.session = session
    }
}

final class PreviewView: UIView {
    // MARK: - Overrides
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    // MARK: - Properties
    var previewLayer: AVCaptureVideoPreviewLayer {
        guard let previewLayer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("PreviewView must use AVCaptureVideoPreviewLayer")
        }

        return previewLayer
    }
}
