//
//  CameraPreviewView.swift
//  Pishoot
//
//  Created by Muhammad Zikrurridho Afwani on 25/06/24.
//

import SwiftUI
import AVFoundation

struct CameraPreviewView: UIViewRepresentable {
    class CameraPreview: UIView {
        var previewLayer: AVCaptureVideoPreviewLayer
        var blackScreenView: UIView
        
        override init(frame: CGRect) {
            previewLayer = AVCaptureVideoPreviewLayer()
            blackScreenView = UIView()
            blackScreenView.backgroundColor = .black
            blackScreenView.alpha = 0
            super.init(frame: frame)
            layer.addSublayer(previewLayer)
            addSubview(blackScreenView)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            previewLayer.frame = bounds
            blackScreenView.frame = bounds
        }
    }
    
    var session: AVCaptureSession
    @Binding var isBlackScreenVisible: Bool
    
    func makeUIView(context: Context) -> CameraPreview {
        let view = CameraPreview()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        
        if let wideAngleInput = session.inputs.first(where: { ($0 as? AVCaptureDeviceInput)?.device.deviceType == .builtInWideAngleCamera }) as? AVCaptureDeviceInput,
           let port = wideAngleInput.ports.first(where: { $0.mediaType == .video }) {
            let connection = AVCaptureConnection(inputPort: port, videoPreviewLayer: view.previewLayer)
            if session.canAddConnection(connection) {
                session.addConnection(connection)
            }
            
            do {
                try wideAngleInput.device.lockForConfiguration()
                wideAngleInput.device.videoZoomFactor = 1.0
                wideAngleInput.device.unlockForConfiguration()
            } catch {
                print("Error setting initial zoom factor: \(error)")
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: CameraPreview, context: Context) {
        uiView.blackScreenView.alpha = isBlackScreenVisible ? 1 : 0
    }
}
