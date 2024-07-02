////
////  CameraPreviewView.swift
////  Pishoot
////
////  Created by Muhammad Zikrurridho Afwani on 25/06/24.
////
//
//import SwiftUI
//import AVFoundation
//
//struct CameraPreviewView: UIViewRepresentable {
//    class CameraPreview: UIView {
//        var previewLayer: AVCaptureVideoPreviewLayer
//        
//        override init(frame: CGRect) {
//            previewLayer = AVCaptureVideoPreviewLayer()
//            super.init(frame: frame)
//            layer.addSublayer(previewLayer)
//        }
//        
//        required init?(coder: NSCoder) {
//            fatalError("init(coder:) has not been implemented")
//        }
//        
//        override func layoutSubviews() {
//            super.layoutSubviews()
//            previewLayer.frame = bounds
//        }
//    }
//    
//    var session: AVCaptureSession
//    
//    func makeUIView(context: Context) -> CameraPreview {
//        let view = CameraPreview()
//        view.previewLayer.session = session
//        view.previewLayer.videoGravity = .resizeAspectFill
//        return view
//    }
//    
//    func updateUIView(_ uiView: CameraPreview, context: Context) {}
//}

//import SwiftUI
//import AVFoundation
//
//struct CameraPreviewView: UIViewRepresentable {
//    class CameraPreview: UIView {
//        var previewLayer: AVCaptureVideoPreviewLayer
//        
//        override init(frame: CGRect) {
//            previewLayer = AVCaptureVideoPreviewLayer()
//            super.init(frame: frame)
//            layer.addSublayer(previewLayer)
//        }
//        
//        required init?(coder: NSCoder) {
//            fatalError("init(coder:) has not been implemented")
//        }
//        
//        override func layoutSubviews() {
//            super.layoutSubviews()
//            previewLayer.frame = bounds
//        }
//    }
//    
//    var session: AVCaptureMultiCamSession
//    
//    func makeUIView(context: Context) -> CameraPreview {
//        let view = CameraPreview()
//        view.previewLayer.session = session
//        view.previewLayer.videoGravity = .resizeAspectFill
//        
//        // Set up the preview layer to show only the wide-angle camera
//        if let wideAngleInput = session.inputs.first(where: { ($0 as? AVCaptureDeviceInput)?.device.deviceType == .builtInWideAngleCamera }) as? AVCaptureDeviceInput,
//           let port = wideAngleInput.ports.first(where: { $0.mediaType == .video }) {
//            let connection = AVCaptureConnection(inputPort: port, videoPreviewLayer: view.previewLayer)
//            if session.canAddConnection(connection) {
//                session.addConnection(connection)
//            }
//        }
//        
//        return view
//    }
//    
//    func updateUIView(_ uiView: CameraPreview, context: Context) {}
//}
