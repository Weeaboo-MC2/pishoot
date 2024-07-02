//////
//////  ContentView.swift
//////  Pishoot
//////
//////  Created by Muhammad Zikrurridho Afwani on 25/06/24.
//////
////
////import SwiftUI
////
////struct ContentView: View {
////    @StateObject private var cameraViewModel = CameraViewModel()
////    @State private var lastPhoto: UIImage? = nil
////    @State var isAdditionalSettingsOpen: Bool = false
////
////    var body: some View {
////        VStack {
////            TopBarView(toggleFlash: {
////                cameraViewModel.toggleFlash()
////            }, toggleAdditionalSettings: toggleAdditionalSettings, isFlashOn: cameraViewModel.isFlashOn,
////                       isAdditionalSettingsOpen: isAdditionalSettingsOpen)
////            .padding(.top, 40)
////            .padding(.horizontal)
////            
////            CameraPreviewView(session: cameraViewModel.session)
////                .edgesIgnoringSafeArea(.all)
////                .overlay(
////                    VStack {
////                        
////                        Spacer()
////                        
////                        if isAdditionalSettingsOpen {
////                            MainAdditionalSetting()
////                        }
////                        
////                        BottomBarView(lastPhoto: lastPhoto, captureAction: {
////                            cameraViewModel.capturePhotos { image in
////                                self.lastPhoto = image
////                            }
////                        }, openPhotosApp: {
////                            PhotoLibraryHelper.openPhotosApp()
////                        })
////                        .padding(.bottom, 20)
////                    }
////                )
////        }
////        .onAppear {
////            cameraViewModel.startSession()
////            PhotoLibraryHelper.fetchLastPhoto { image in
////                self.lastPhoto = image
////            }
////        }
////        .onDisappear {
////            cameraViewModel.stopSession()
////        }
////        .statusBar(hidden: true)
////        .ignoresSafeArea()
////    }
////    
////    func toggleAdditionalSettings() {
////        isAdditionalSettingsOpen.toggle()
////    }
////}
////
////#Preview {
////    ContentView()
////}
//
//import SwiftUI
//import AVFoundation
//
//struct ContentView: View {
//    @StateObject private var cameraViewModel = CameraViewModel()
//    @State private var lastPhotos: [UIImage] = []
//    @State var isAdditionalSettingsOpen: Bool = false
//
//    var body: some View {
//        VStack {
//            TopBarView(toggleFlash: {
//                cameraViewModel.toggleFlash()
//            }, toggleAdditionalSettings: toggleAdditionalSettings, isFlashOn: cameraViewModel.isFlashOn,
//                       isAdditionalSettingsOpen: isAdditionalSettingsOpen)
//            .padding(.top, 40)
//            .padding(.horizontal)
//            
//            if let session = cameraViewModel.session {
//                CameraPreviewView(session: session)
//                    .edgesIgnoringSafeArea(.all)
//                    .overlay(
//                        VStack {
//                            Spacer()
//                            
//                            if isAdditionalSettingsOpen {
//                                MainAdditionalSetting()
//                            }
//                            
//                            BottomBarView(lastPhoto: lastPhotos.first, captureAction: {
//                                cameraViewModel.capturePhotos { images in
//                                    self.lastPhotos = images
//                                }
//                            }, openPhotosApp: {
//                                PhotoLibraryHelper.openPhotosApp()
//                            })
//                            .padding(.bottom, 20)
//                        }
//                    )
//            } else {
//                Text("Multi-cam not supported on this device")
//            }
//        }
//        .onAppear {
//            cameraViewModel.startSession()
//            PhotoLibraryHelper.fetchLastPhoto { image in
//                if let image = image {
//                    self.lastPhotos = [image]
//                }
//            }
//        }
//        .onDisappear {
//            cameraViewModel.stopSession()
//        }
//        .statusBar(hidden: true)
//        .ignoresSafeArea()
//    }
//    
//    func toggleAdditionalSettings() {
//        isAdditionalSettingsOpen.toggle()
//    }
//}
//
//#Preview {
//    ContentView()
//}

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var lastPhotos: [UIImage] = []
    @State var isAdditionalSettingsOpen: Bool = false

    var body: some View {
        VStack {
            TopBarView(toggleFlash: {
                cameraViewModel.toggleFlash()
            }, toggleAdditionalSettings: toggleAdditionalSettings, isFlashOn: cameraViewModel.isFlashOn,
                       isAdditionalSettingsOpen: isAdditionalSettingsOpen)
            .padding(.top, 40)
            .padding(.horizontal)
            
            if let session = cameraViewModel.session {
                CameraPreviewView(session: session)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        VStack {
                            Spacer()
                            
                            if isAdditionalSettingsOpen {
                                MainAdditionalSetting()
                            }
                            
                            BottomBarView(lastPhoto: lastPhotos.first, captureAction: {
                                cameraViewModel.capturePhotos { images in
                                    self.lastPhotos = images
                                }
                            }, openPhotosApp: {
                                PhotoLibraryHelper.openPhotosApp()
                            })
                            .padding(.bottom, 20)
                        }
                    )
            } else {
                Text("Camera not available")
            }
        }
        .onAppear {
            cameraViewModel.startSession()
            PhotoLibraryHelper.fetchLastPhoto { image in
                if let image = image {
                    self.lastPhotos = [image]
                }
            }
        }
        .onDisappear {
            cameraViewModel.stopSession()
        }
        .statusBar(hidden: true)
        .ignoresSafeArea()
    }
    
    func toggleAdditionalSettings() {
        isAdditionalSettingsOpen.toggle()
    }
}

struct CameraPreviewView: UIViewRepresentable {
    class CameraPreview: UIView {
        var previewLayer: AVCaptureVideoPreviewLayer
        
        override init(frame: CGRect) {
            previewLayer = AVCaptureVideoPreviewLayer()
            super.init(frame: frame)
            layer.addSublayer(previewLayer)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            previewLayer.frame = bounds
        }
    }
    
    var session: AVCaptureSession
    
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
    
    func updateUIView(_ uiView: CameraPreview, context: Context) {}
}
