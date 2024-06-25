//
//  CameraViewModel.swift
//  Pishoot
//
//  Created by Muhammad Zikrurridho Afwani on 25/06/24.
//

import SwiftUI
import AVFoundation
import Photos

class CameraViewModel: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    @Published var session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    private var backWideAngleCamera: AVCaptureDevice?
    private var backUltraWideCamera: AVCaptureDevice?
    private var isCapturingPhoto = false
    @Published var isFlashOn = false
    
    override init() {
        super.init()
        configureSession()
    }
    
    private func configureSession() {
        session.beginConfiguration()
        
        if let backWideAngleCamera = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
            self.backWideAngleCamera = backWideAngleCamera
            configureInput(for: backWideAngleCamera)
        }
        
        if let backUltraWideCamera = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) {
            self.backUltraWideCamera = backUltraWideCamera
        }
        
        session.addOutput(photoOutput)
        session.commitConfiguration()
    }
    
    private func configureInput(for device: AVCaptureDevice) {
        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            print("Error configuring input: \(error)")
        }
    }
    
    func startSession() {
        if !session.isRunning {
            session.startRunning()
        }
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
    }
    
    func capturePhotos(completion: @escaping (UIImage?) -> Void) {
        guard !isCapturingPhoto else { return }
        isCapturingPhoto = true
        
        let devices: [(AVCaptureDevice?, CGFloat)] = [
            (backWideAngleCamera, 1.0),
            (backWideAngleCamera, 2.0),
            (backUltraWideCamera, 1.0)
        ]
        
        captureNextPhoto(devices: devices) { [weak self] in
            self?.setNormalLens()
            PhotoLibraryHelper.fetchLastPhoto(completion: completion)
        }
    }
    
    private func captureNextPhoto(devices: [(AVCaptureDevice?, CGFloat)], completion: @escaping () -> Void) {
        guard let (device, zoomFactor) = devices.first else {
            isCapturingPhoto = false
            completion()
            return
        }
        
        guard let unwrappedDevice = device else {
            captureNextPhoto(devices: Array(devices.dropFirst()), completion: completion)
            return
        }
        
        capturePhoto(using: unwrappedDevice, zoomFactor: zoomFactor) { [weak self] in
            self?.captureNextPhoto(devices: Array(devices.dropFirst()), completion: completion)
        }
    }
    
    private func capturePhoto(using device: AVCaptureDevice, zoomFactor: CGFloat, completion: @escaping () -> Void) {
        DispatchQueue.global().async {
            self.session.beginConfiguration()
            
            // Remove existing inputs
            for input in self.session.inputs {
                self.session.removeInput(input)
            }
            
            // Add new input
            self.configureInput(for: device)
            
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = zoomFactor
                device.unlockForConfiguration()
            } catch {
                print("Error locking configuration: \(error)")
            }
            
            self.session.commitConfiguration()
            
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.flashMode = self.isFlashOn ? .on : .off
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                completion()
            }
        }
    }
    
    func setNormalLens() {
        DispatchQueue.global().async {
            self.session.beginConfiguration()
            for input in self.session.inputs {
                self.session.removeInput(input)
            }
            if let backWideAngleCamera = self.backWideAngleCamera {
                self.configureInput(for: backWideAngleCamera)
                do {
                    try backWideAngleCamera.lockForConfiguration()
                    backWideAngleCamera.videoZoomFactor = 1.0
                    backWideAngleCamera.unlockForConfiguration()
                } catch {
                    print("Error resetting zoom factor: \(error)")
                }
            }
            self.session.commitConfiguration()
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("Error capturing photo: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: imageData) else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        PhotoLibraryHelper.fetchLastPhoto { _ in }
    }
}

