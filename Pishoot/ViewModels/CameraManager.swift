import AVFoundation
import Photos
import UIKit
import Combine

class CameraManager: NSObject, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    var session: AVCaptureMultiCamSession?
    private var wideAngleOutput: AVCapturePhotoOutput?
    private var ultraWideOutput: AVCapturePhotoOutput?
    
    private var wideAngleCamera: AVCaptureDevice?
    private var ultraWideCamera: AVCaptureDevice?
    
    private var videoDataOutput: AVCaptureVideoDataOutput?
    @Published var selectedZoomLevel: CGFloat = 1.0
    @Published var isFlashOn: Bool = false
    @Published var isCapturingPhoto: Bool = false
    @Published var isBlackScreenVisible: Bool = false
    
    private var capturedImages: [UIImage] = []
    private var completion: (([UIImage]) -> Void)?
    
    static let shared = CameraManager()
    
    private override init() {
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
        setupVideoDataOutput()
        
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
    
    private func setupVideoDataOutput() {
        let videoDataOutput = AVCaptureVideoDataOutput()
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if session?.canAddOutput(videoDataOutput) == true {
            session?.addOutput(videoDataOutput)
        }
        self.videoDataOutput = videoDataOutput
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
        
        guard let wideAngleCamera = wideAngleCamera else { return }
        do {
            if wideAngleCamera.videoZoomFactor != 1.0 {
                try wideAngleCamera.lockForConfiguration()
                wideAngleCamera.videoZoomFactor = 1.0
                wideAngleCamera.unlockForConfiguration()
            }
        } catch {
            print("Error setting zoom factor: \(error)")
        }
        
        if isFlashOn {
            turnTorch(on: true)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isBlackScreenVisible = true
            
            self.ultraWideOutput?.capturePhoto(with: photoSettings, delegate: self)
            self.wideAngleOutput?.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func captureZoomedPhotos() {
        guard let wideAngleCamera = wideAngleCamera else { return }
        do {
            try wideAngleCamera.lockForConfiguration()
            wideAngleCamera.videoZoomFactor = 2.0
            let zoomedPhotoSettings = AVCapturePhotoSettings()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.wideAngleOutput?.capturePhoto(with: zoomedPhotoSettings, delegate: self)
            }
            wideAngleCamera.unlockForConfiguration()
        } catch {
            print("Error setting zoom factor: \(error)")
        }
    }
    
    func setZoomLevel(zoomLevel: CGFloat) {
        selectedZoomLevel = zoomLevel
        if zoomLevel == 0.5 {
            switchToUltraWideCamera()
        } else {
            switchToWideAngleCamera(zoomLevel: zoomLevel)
        }
    }
    
    private func switchToUltraWideCamera() {
        guard let session = session, let ultraWideCamera = ultraWideCamera else { return }
        session.beginConfiguration()
        for input in session.inputs {
            session.removeInput(input)
        }
        do {
            let input = try AVCaptureDeviceInput(device: ultraWideCamera)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            session.commitConfiguration()
        } catch {
            print("Error switching to ultra-wide camera: \(error)")
        }
    }
    
    private func switchToWideAngleCamera(zoomLevel: CGFloat) {
        guard let session = session, let wideAngleCamera = wideAngleCamera else { return }
        session.beginConfiguration()
        for input in session.inputs {
            session.removeInput(input)
        }
        do {
            let input = try AVCaptureDeviceInput(device: wideAngleCamera)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            wideAngleCamera.videoZoomFactor = zoomLevel
            session.commitConfiguration()
        } catch {
            print("Error switching to wide-angle camera: \(error)")
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                print("Error capturing photo: \(error)")
                self.isBlackScreenVisible = false
                if self.isFlashOn {
                    self.turnTorch(on: false)
                }
                return
            }
            
            guard let imageData = photo.fileDataRepresentation(),
                  let image = UIImage(data: imageData) else { return }
            
            PhotoLibraryHelper.requestPhotoLibraryPermission { [weak self] authorized in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if authorized {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        self.capturedImages.append(image)
                        
                        if self.capturedImages.count == 2 {
                            print("captured 2 images")
                            self.captureZoomedPhotos()
                        }
                        
                        if self.capturedImages.count == 3 {
                            self.backToNormalLens()
                            print("captured 3 images")
                            self.completion?(self.capturedImages)
                            self.completion = nil
                            self.isCapturingPhoto = false
                        }
                    } else {
                        print("Photo library access not authorized")
                        self.isBlackScreenVisible = false
                        if self.isFlashOn {
                            self.turnTorch(on: false)
                        }
                    }
                }
            }
        }
    }
    
    func backToNormalLens() {
        if selectedZoomLevel == 0.5 {
            switchToUltraWideCamera()
        } else {
            switchToWideAngleCamera(zoomLevel: selectedZoomLevel)
        }
        
        // Delay hiding the black screen and turning off the torch
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.isBlackScreenVisible = false
            if self.isFlashOn {
                self.turnTorch(on: false)
            }
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        
        let image = UIImage(cgImage: cgImage)
        sendPreviewToWatch(image)
    }
    
    private func sendPreviewToWatch(_ image: UIImage) {
        WatchConnectivityManager.shared.sendPreviewToWatch(image)
    }
    
    func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func turnTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            if on {
                try device.setTorchModeOn(level: 1.0)
            }
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used: \(error)")
        }
    }
}
