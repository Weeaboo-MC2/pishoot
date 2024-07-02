//////
//////  CameraViewModel.swift
//////  Pishoot
//////
//////  Created by Muhammad Zikrurridho Afwani on 25/06/24.
//////
////
////import SwiftUI
////import AVFoundation
////import Photos
////
////class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
////    @Published var session = AVCaptureSession()
////    private let photoOutput = AVCapturePhotoOutput()
////    
////    private var backWideAngleCamera: AVCaptureDevice?
////    private var backUltraWideCamera: AVCaptureDevice?
////    private var isCapturingPhoto = false
////    @Published var isFlashOn = false
////    
////    override init() {
////        super.init()
////        configureSession()
////    }
////    
////    private func configureSession() {
////        session.beginConfiguration()
////        
////        if let backWideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
////            self.backWideAngleCamera = backWideAngleCamera
////            configureInput(for: backWideAngleCamera)
////        }
////        
////        if let backUltraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
////            self.backUltraWideCamera = backUltraWideCamera
////        }
////        
////        session.addOutput(photoOutput)
////        session.commitConfiguration()
////    }
////    
////    private func configureInput(for device: AVCaptureDevice) {
////        do {
////            let input = try AVCaptureDeviceInput(device: device)
////            if session.canAddInput(input) {
////                session.addInput(input)
////            }
////        } catch {
////            print("Error configuring input: \(error)")
////        }
////    }
////    
////    func startSession() {
////        if !session.isRunning {
////            session.startRunning()
////        }
////    }
////    
////    func stopSession() {
////        if session.isRunning {
////            session.stopRunning()
////        }
////    }
////    
////    func toggleFlash() {
////        isFlashOn.toggle()
////    }
////    
////    func capturePhotos(completion: @escaping (UIImage?) -> Void) {
////        guard !isCapturingPhoto else { return }
////        isCapturingPhoto = true
////        
////        let devices: [(AVCaptureDevice?, CGFloat)] = [
////            (backWideAngleCamera, 1.0),
////            (backUltraWideCamera, 1.0)
////        ]
////        
////        captureNextPhoto(devices: devices) { [weak self] in
////            self?.setNormalLens()
////            PhotoLibraryHelper.fetchLastPhoto(completion: completion)
////        }
////    }
////    
////    private func captureNextPhoto(devices: [(AVCaptureDevice?, CGFloat)], completion: @escaping () -> Void) {
////        guard let (device, zoomFactor) = devices.first else {
////            isCapturingPhoto = false
////            completion()
////            return
////        }
////        
////        guard let unwrappedDevice = device else {
////            captureNextPhoto(devices: Array(devices.dropFirst()), completion: completion)
////            return
////        }
////        
////        capturePhoto(using: unwrappedDevice, zoomFactor: zoomFactor) { [weak self] in
////            self?.captureNextPhoto(devices: Array(devices.dropFirst()), completion: completion)
////        }
////    }
////    
////    private func capturePhoto(using device: AVCaptureDevice, zoomFactor: CGFloat, completion: @escaping () -> Void) {
////        DispatchQueue.global().async {
////            self.session.beginConfiguration()
////            
////            // Remove existing inputs
////            for input in self.session.inputs {
////                self.session.removeInput(input)
////            }
////            
////            // Add new input
////            self.configureInput(for: device)
////            
////            do {
////                try device.lockForConfiguration()
////                device.videoZoomFactor = zoomFactor
////                device.unlockForConfiguration()
////            } catch {
////                print("Error locking configuration: \(error)")
////            }
////            
////            self.session.commitConfiguration()
////            
////            let photoSettings = AVCapturePhotoSettings()
////            photoSettings.flashMode = self.isFlashOn ? .on : .off
////            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
////            
////            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
////                completion()
////            }
////        }
////    }
////    
////    func setNormalLens() {
////        DispatchQueue.global().async {
////            self.session.beginConfiguration()
////            for input in self.session.inputs {
////                self.session.removeInput(input)
////            }
////            if let backWideAngleCamera = self.backWideAngleCamera {
////                self.configureInput(for: backWideAngleCamera)
////                do {
////                    try backWideAngleCamera.lockForConfiguration()
////                    backWideAngleCamera.videoZoomFactor = 1.0
////                    backWideAngleCamera.unlockForConfiguration()
////                } catch {
////                    print("Error resetting zoom factor: \(error)")
////                }
////            }
////            self.session.commitConfiguration()
////        }
////    }
////    
////    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
////        if let error = error {
////            print("Error capturing photo: \(error)")
////            return
////        }
////        
////        guard let imageData = photo.fileDataRepresentation() else { return }
////        guard let image = UIImage(data: imageData) else { return }
////        
////        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
////        PhotoLibraryHelper.fetchLastPhoto { _ in }
////    }
////}
////
//
//import SwiftUI
//import AVFoundation
//import Photos
//
//class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
//    @Published var session: AVCaptureMultiCamSession?
//    private var wideAngleOutput: AVCapturePhotoOutput?
//    private var ultraWideOutput: AVCapturePhotoOutput?
//    
//    private var wideAngleCamera: AVCaptureDevice?
//    private var ultraWideCamera: AVCaptureDevice?
//    
//    @Published var isFlashOn = false
//    private var isCapturingPhoto = false
//    
//    override init() {
//        super.init()
//        setupSession()
//    }
//    
//    private func setupSession() {
//        guard AVCaptureMultiCamSession.isMultiCamSupported else {
//            print("Multi-cam not supported on this device")
//            return
//        }
//        
//        let session = AVCaptureMultiCamSession()
//        self.session = session
//        
//        session.beginConfiguration()
//        
//        // Setup wide angle camera
//        if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
//            self.wideAngleCamera = wideAngleCamera
//            setupCamera(wideAngleCamera, to: session)
//        }
//        
//        // Setup ultra wide camera
//        if let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
//            self.ultraWideCamera = ultraWideCamera
//            setupCamera(ultraWideCamera, to: session)
//        }
//        
//        session.commitConfiguration()
//    }
//    
//    private func setupCamera(_ device: AVCaptureDevice, to session: AVCaptureMultiCamSession) {
//        do {
//            let input = try AVCaptureDeviceInput(device: device)
//            if session.canAddInput(input) {
//                session.addInputWithNoConnections(input)
//            }
//            
//            let output = AVCapturePhotoOutput()
//            if session.canAddOutput(output) {
//                session.addOutputWithNoConnections(output)
//            }
//            
//            let connection = AVCaptureConnection(inputPorts: input.ports, output: output)
//            if session.canAddConnection(connection) {
//                session.addConnection(connection)
//            }
//            
//            if device.deviceType == .builtInWideAngleCamera {
//                wideAngleOutput = output
//            } else if device.deviceType == .builtInUltraWideCamera {
//                ultraWideOutput = output
//            }
//        } catch {
//            print("Error setting up camera: \(error)")
//        }
//    }
//    
//    func startSession() {
//        session?.startRunning()
//    }
//    
//    func stopSession() {
//        session?.stopRunning()
//    }
//    
//    func toggleFlash() {
//        isFlashOn.toggle()
//    }
//    
//    func capturePhotos(completion: @escaping ([UIImage]) -> Void) {
//        guard let session = session, !isCapturingPhoto else { return }
//        isCapturingPhoto = true
//        
//        var capturedImages: [UIImage] = []
//        let group = DispatchGroup()
//        
//        let photoSettings = AVCapturePhotoSettings()
//        photoSettings.flashMode = isFlashOn ? .on : .off
//        
//        if let wideAngleOutput = wideAngleOutput {
//            group.enter()
//            wideAngleOutput.capturePhoto(with: photoSettings, delegate: self)
//        }
//        
//        if let ultraWideOutput = ultraWideOutput {
//            group.enter()
//            ultraWideOutput.capturePhoto(with: photoSettings, delegate: self)
//        }
//        
//        group.notify(queue: .main) {
//            self.isCapturingPhoto = false
//            completion(capturedImages)
//        }
//    }
//    
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        if let error = error {
//            print("Error capturing photo: \(error)")
//            return
//        }
//        
//        guard let imageData = photo.fileDataRepresentation(),
//              let image = UIImage(data: imageData) else { return }
//        
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//        
//        // You might want to implement a way to associate each captured image with its respective camera
//        // For now, we're just saving all images
//    }
//}

import SwiftUI
import AVFoundation
import Photos

class CameraViewModela: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var session: AVCaptureMultiCamSession?
    private var wideAngleOutput: AVCapturePhotoOutput?
    private var ultraWideOutput: AVCapturePhotoOutput?
    private var telephotoOutput: AVCapturePhotoOutput?
    
    private var wideAngleCamera: AVCaptureDevice?
    private var ultraWideCamera: AVCaptureDevice?
    private var telephotoCamera: AVCaptureDevice?
    
    @Published var isFlashOn = false
    private var isCapturingPhoto = false
    private var capturedImages: [UIImage] = []
    private var completion: (([UIImage]) -> Void)?
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        guard AVCaptureMultiCamSession.isMultiCamSupported else {
            print("Multi-cam not supported on this device")
            return
        }
        
        let session = AVCaptureMultiCamSession()
        self.session = session
        
        session.beginConfiguration()
        
        setupCamera(.builtInWideAngleCamera, to: session)
        setupCamera(.builtInUltraWideCamera, to: session)
        setupCamera(.builtInTelephotoCamera, to: session)
        
        session.commitConfiguration()
    }
    
    private func setupCamera(_ deviceType: AVCaptureDevice.DeviceType, to session: AVCaptureMultiCamSession) {
        guard let device = AVCaptureDevice.default(deviceType, for: .video, position: .back) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInputWithNoConnections(input)
            }
            
            let output = AVCapturePhotoOutput()
            if session.canAddOutput(output) {
                session.addOutputWithNoConnections(output)
            }
            
            let connection = AVCaptureConnection(inputPorts: input.ports, output: output)
            if session.canAddConnection(connection) {
                session.addConnection(connection)
            }
            
            switch device.deviceType {
            case .builtInWideAngleCamera:
                wideAngleOutput = output
                wideAngleCamera = device
            case .builtInUltraWideCamera:
                ultraWideOutput = output
                ultraWideCamera = device
            case .builtInTelephotoCamera:
                telephotoOutput = output
                telephotoCamera = device
            default:
                break
            }
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    func capturePhotos(completion: @escaping ([UIImage]) -> Void) {
        guard let session = session, !isCapturingPhoto else { return }
        isCapturingPhoto = true
        capturedImages.removeAll()
        self.completion = completion
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = isFlashOn ? .on : .off
        
        wideAngleOutput?.capturePhoto(with: photoSettings, delegate: self)
        ultraWideOutput?.capturePhoto(with: photoSettings, delegate: self)
        
        // Capture telephoto (2x zoom) image after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            if let telephotoCamera = self.telephotoCamera {
                do {
                    try telephotoCamera.lockForConfiguration()
                    telephotoCamera.videoZoomFactor = 2.0 // Set 2x zoom
                    telephotoCamera.unlockForConfiguration()
                } catch {
                    print("Error setting zoom: \(error)")
                }
            }
            
            self.telephotoOutput?.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }
        
        PhotoLibraryHelper.requestPhotoLibraryPermission { [weak self] authorized in
            guard let self = self else { return }
            if authorized {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                self.capturedImages.append(image)
                
                if self.capturedImages.count == 3 {
                    DispatchQueue.main.async {
                        self.completion?(self.capturedImages)
                        self.completion = nil
                        self.isCapturingPhoto = false
                    }
                }
            } else {
                print("Photo library access not authorized")
                // Handle the case where the user hasn't granted permission
            }
        }
    }
    
    // ... (other methods remain the same)
}

import SwiftUI
import AVFoundation
import Photos

class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var session: AVCaptureMultiCamSession?
    private var wideAngleOutput: AVCapturePhotoOutput?
    private var ultraWideOutput: AVCapturePhotoOutput?
    
    private var wideAngleCamera: AVCaptureDevice?
    private var ultraWideCamera: AVCaptureDevice?
    
    @Published var isFlashOn = false
    private var isCapturingPhoto = false
    private var capturedImages: [UIImage] = []
    private var completion: (([UIImage]) -> Void)?
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        guard AVCaptureMultiCamSession.isMultiCamSupported else {
            print("Multi-cam not supported on this device")
            return
        }
        
        let session = AVCaptureMultiCamSession()
        self.session = session
        
        session.beginConfiguration()
        
        setupCamera(.builtInWideAngleCamera, to: session)
        setupCamera(.builtInUltraWideCamera, to: session)
        session.commitConfiguration()
    }

    
    private func setupCamera(_ deviceType: AVCaptureDevice.DeviceType, to session: AVCaptureMultiCamSession) {
        guard let device = AVCaptureDevice.default(deviceType, for: .video, position: .back) else { return }
        
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInputWithNoConnections(input)
            }
            
            let output = AVCapturePhotoOutput()
            if session.canAddOutput(output) {
                session.addOutputWithNoConnections(output)
            }
            
            let connection = AVCaptureConnection(inputPorts: input.ports, output: output)
            if session.canAddConnection(connection) {
                session.addConnection(connection)
            }
            
            if device.deviceType == .builtInWideAngleCamera {
                wideAngleOutput = output
                wideAngleCamera = device
            } else if device.deviceType == .builtInUltraWideCamera {
                ultraWideOutput = output
                ultraWideCamera = device
            }
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    func startSession() {
        session?.startRunning()
    }
    
    func stopSession() {
        session?.stopRunning()
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
    }
    
    func capturePhotos(completion: @escaping ([UIImage]) -> Void) {
        guard let _ = session, !isCapturingPhoto else { return }
        isCapturingPhoto = true
        capturedImages.removeAll()
        self.completion = completion
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = isFlashOn ? .on : .off
        
        ultraWideOutput?.capturePhoto(with: photoSettings, delegate: self)
        wideAngleOutput?.capturePhoto(with: photoSettings, delegate: self)

    }
    
    func captureZoomedPhotos() {
        guard let wideAngleCamera = wideAngleCamera else { return }
            do {
                try wideAngleCamera.lockForConfiguration()
                wideAngleCamera.videoZoomFactor = 2.0 // Set the digital zoom factor
                let zoomedPhotoSettings = AVCapturePhotoSettings()
                zoomedPhotoSettings.flashMode = isFlashOn ? .on : .off
                wideAngleOutput?.capturePhoto(with: zoomedPhotoSettings, delegate: self)
                wideAngleCamera.unlockForConfiguration()
            } catch {
                print("Error setting zoom factor: \(error)")
            }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else { return }
        
        PhotoLibraryHelper.requestPhotoLibraryPermission { [weak self] authorized in
            guard let self = self else { return }
            if authorized {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                self.capturedImages.append(image)
                
                if self.capturedImages.count == 2 {
                    print("captured 2 images")
                    captureZoomedPhotos()
                }
                
                if self.capturedImages.count == 3 {
                    guard let wideAngleCamera = wideAngleCamera else { return }
                        do {
                            try wideAngleCamera.lockForConfiguration()
                            wideAngleCamera.videoZoomFactor = 1.0 // Set the digital zoom factor
                            wideAngleCamera.unlockForConfiguration()
                        } catch {
                            print("Error setting zoom factor: \(error)")
                        }
                    print("captured 3 images")
                    DispatchQueue.main.async {
                        self.completion?(self.capturedImages)
                        self.completion = nil
                        self.isCapturingPhoto = false
                    }
                }
            } else {
                print("Photo library access not authorized")
                // Handle the case where the user hasn't granted permission
            }
        }
    }
    
}

//import SwiftUI
//import AVFoundation
//import Photos
//
//class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
//    @Published var session: AVCaptureMultiCamSession?
//    private var wideAngleOutput: AVCapturePhotoOutput?
//    private var ultraWideOutput: AVCapturePhotoOutput?
//    private var telephotoOutput: AVCapturePhotoOutput?
//
//    private var wideAngleCamera: AVCaptureDevice?
//    private var zoomAngleCamera: AVCaptureDevice?
//    private var ultraWideCamera: AVCaptureDevice?
//    private var telephotoCamera: AVCaptureDevice?
//
//    @Published var isFlashOn = false
//    private var isCapturingPhoto = false
//    private var capturedImages: [UIImage] = []
//    private var completion: (([UIImage]) -> Void)?
//
//    override init() {
//        super.init()
//        setupSession()
//    }
//
//    private func setupSession() {
//        guard AVCaptureMultiCamSession.isMultiCamSupported else {
//            print("Multi-cam not supported on this device")
//            return
//        }
//
//        let session = AVCaptureMultiCamSession()
//        self.session = session
//
//        session.beginConfiguration()
//
//        setupCamera(.builtInWideAngleCamera, to: session)
//        setupCamera(.builtInUltraWideCamera, to: session)
//        setupCamera(.builtInTelephotoCamera, to: session)
//
//        session.commitConfiguration()
//    }
//
//    private func setupCamera(_ deviceType: AVCaptureDevice.DeviceType, to session: AVCaptureMultiCamSession) {
//        guard let device = AVCaptureDevice.default(deviceType, for: .video, position: .back) else { return }
//
//        do {
//            let input = try AVCaptureDeviceInput(device: device)
//            if session.canAddInput(input) {
//                session.addInputWithNoConnections(input)
//            }
//
//            let output = AVCapturePhotoOutput()
//            if session.canAddOutput(output) {
//                session.addOutputWithNoConnections(output)
//            }
//
//            let connection = AVCaptureConnection(inputPorts: input.ports, output: output)
//            if session.canAddConnection(connection) {
//                session.addConnection(connection)
//            }
//
//            if device.deviceType == .builtInWideAngleCamera {
//                wideAngleOutput = output
//                wideAngleCamera = device
//            } else if device.deviceType == .builtInUltraWideCamera {
//                ultraWideOutput = output
//                ultraWideCamera = device
//            } else if device.deviceType == .builtInTelephotoCamera {
//                telephotoOutput = output
//                telephotoCamera = device
//            }
//        } catch {
//            print("Error setting up camera: \(error)")
//        }
//    }
//
//    func startSession() {
//        session?.startRunning()
//    }
//
//    func stopSession() {
//        session?.stopRunning()
//    }
//
//    func toggleFlash() {
//        isFlashOn.toggle()
//    }
//
//    func capturePhotos(completion: @escaping ([UIImage]) -> Void) {
//        guard let session = session, !isCapturingPhoto else { return }
//        isCapturingPhoto = true
//        capturedImages.removeAll()
//        self.completion = completion
//
//        capturePhoto(from: wideAngleOutput)
//        capturePhoto(from: ultraWideOutput)
//        if let telephotoOutput = telephotoOutput {
//            capturePhoto(from: telephotoOutput)
//        } else {
//            print("ddd")
//            captureZoomedPhoto()
//        }
//    }
//
//    private func capturePhoto(from output: AVCapturePhotoOutput?) {
//        let photoSettings = AVCapturePhotoSettings()
//        photoSettings.flashMode = isFlashOn ? .on : .off
//        output?.capturePhoto(with: photoSettings, delegate: self)
//    }
//    
//    private func captureZoomedPhoto() {
//            guard let wideAngleCamera = wideAngleCamera else { return }
//            do {
//                try wideAngleCamera.lockForConfiguration()
//                wideAngleCamera.videoZoomFactor = 2.0 // Set the digital zoom factor
//                let zoomedPhotoSettings = AVCapturePhotoSettings()
//                zoomedPhotoSettings.flashMode = isFlashOn ? .on : .off
//                wideAngleOutput?.capturePhoto(with: zoomedPhotoSettings, delegate: self)
//                wideAngleCamera.unlockForConfiguration()
//            } catch {
//                print("Error setting zoom factor: \(error)")
//            }
//        }
//
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        if let error = error {
//            print("Error capturing photo: \(error)")
//            return
//        }
//
//        guard let imageData = photo.fileDataRepresentation(),
//              let image = UIImage(data: imageData) else { return }
//
//        PhotoLibraryHelper.requestPhotoLibraryPermission { [weak self] authorized in
//            guard let self = self else { return }
//            if authorized {
//                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                self.capturedImages.append(image)
//
//                if self.capturedImages.count == 3 {
//                    DispatchQueue.main.async {
//                        self.completion?(self.capturedImages)
//                        self.completion = nil
//                        self.isCapturingPhoto = false
//                    }
//                }
//            } else {
//                print("Photo library access not authorized")
//               
//            }
//        }
//    }
//}

//import SwiftUI
//import AVFoundation
//import Photos
//
//class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
//    @Published var session: AVCaptureSession?
//    
//    private var photoOutput: AVCapturePhotoOutput?
//    private var wideAngleCamera: AVCaptureDevice?
//    private var ultraWideCamera: AVCaptureDevice?
//
//    @Published var isFlashOn = false
//    private var isCapturingPhoto = false
//    private var capturedImages: [UIImage] = []
//    private var completion: (([UIImage]) -> Void)?
//    private var currentCaptureIndex = 0
//    private let zoomFactors: [CGFloat] = [0.5, 1.0, 2.0]
//
//    override init() {
//        super.init()
//        setupSession()
//    }
//
//    private func setupSession() {
//        let session = AVCaptureSession()
//        self.session = session
//
//        session.beginConfiguration()
//
//        guard let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
//              let ultraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) else {
//            print("Failed to get camera devices")
//            return
//        }
//
//        self.wideAngleCamera = wideAngleCamera
//        self.ultraWideCamera = ultraWideCamera
//
//        do {
//            let wideAngleInput = try AVCaptureDeviceInput(device: wideAngleCamera)
//            if session.canAddInput(wideAngleInput) {
//                session.addInput(wideAngleInput)
//            }
//
//            let photoOutput = AVCapturePhotoOutput()
//            if session.canAddOutput(photoOutput) {
//                session.addOutput(photoOutput)
//                self.photoOutput = photoOutput
//            }
//        } catch {
//            print("Error setting up camera: \(error)")
//        }
//
//        session.commitConfiguration()
//    }
//
//    func startSession() {
//        DispatchQueue.global(qos: .background).async {
//            self.session?.startRunning()
//        }
//    }
//
//    func stopSession(completion: @escaping () -> Void) {
//        DispatchQueue.global(qos: .background).async {
//            self.session?.stopRunning()
//            DispatchQueue.main.async {
//                completion()
//            }
//        }
//    }
//
//    func toggleFlash() {
//        isFlashOn.toggle()
//    }
//
//    func capturePhotos(completion: @escaping ([UIImage]) -> Void) {
//        guard let session = session, session.isRunning, !isCapturingPhoto else { return }
//        isCapturingPhoto = true
//        capturedImages.removeAll()
//        self.completion = completion
//        currentCaptureIndex = 0
//        captureNextPhoto()
//    }
//
//    private func captureNextPhoto() {
//        guard currentCaptureIndex < zoomFactors.count else {
//            isCapturingPhoto = false
//            self.completion?(capturedImages)
//            return
//        }
//
//        let zoomFactor = zoomFactors[currentCaptureIndex]
//        capturePhoto(zoomFactor: zoomFactor) {
//            self.currentCaptureIndex += 1
//            self.captureNextPhoto()
//        }
//    }
//
//    private func capturePhoto(zoomFactor: CGFloat, completion: @escaping () -> Void) {
//        guard let photoOutput = self.photoOutput else { return }
//
//        let photoSettings = AVCapturePhotoSettings()
//        photoSettings.flashMode = isFlashOn ? .on : .off
//
//        if let device = (zoomFactor < 1.0) ? ultraWideCamera : wideAngleCamera {
//            do {
//                try device.lockForConfiguration()
//                device.videoZoomFactor = (zoomFactor < 1.0) ? 1.0 : zoomFactor
//                device.unlockForConfiguration()
//
//                if let connection = photoOutput.connection(with: .video) {
//                    connection.videoOrientation = .portrait
//                }
//
//                photoOutput.capturePhoto(with: photoSettings, delegate: self)
//            } catch {
//                print("Error setting zoom factor: \(error)")
//            }
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            completion()
//        }
//    }
//
//    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
//        if let error = error {
//            print("Error capturing photo: \(error)")
//            return
//        }
//
//        guard let imageData = photo.fileDataRepresentation(),
//              let image = UIImage(data: imageData) else { return }
//
//        self.capturedImages.append(image)
//
//        if self.capturedImages.count == zoomFactors.count {
//            PhotoLibraryHelper.requestPhotoLibraryPermission { [weak self] authorized in
//                guard let self = self else { return }
//                if authorized {
//                    for image in self.capturedImages {
//                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                    }
//                } else {
//                    print("Photo library access not authorized")
//                }
//                DispatchQueue.main.async {
//                    self.completion?(self.capturedImages)
//                    self.completion = nil
//                    self.isCapturingPhoto = false
//                }
//            }
//        }
//    }
//}
