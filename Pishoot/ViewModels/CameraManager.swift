import AVFoundation
import Photos
import UIKit

class CameraManager: NSObject, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    var session: AVCaptureMultiCamSession?
    private var wideAngleOutput: AVCapturePhotoOutput?
    private var ultraWideOutput: AVCapturePhotoOutput?
    
    private var wideAngleCamera: AVCaptureDevice?
    private var ultraWideCamera: AVCaptureDevice?
    
    private var videoDataOutput: AVCaptureVideoDataOutput?
    
    private var capturedImages: [UIImage] = []
    private var completion: (([UIImage]) -> Void)?
    
    var isFlashOn = false
    var isCapturingPhoto = false
    
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
                    self.captureZoomedPhotos()
                }
                
                if self.capturedImages.count == 3 {
                    self.backToNormalLens()
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
    
    func backToNormalLens() {
        guard let wideAngleCamera = wideAngleCamera else { return }
        do {
            try wideAngleCamera.lockForConfiguration()
            wideAngleCamera.videoZoomFactor = 1.0
            wideAngleCamera.unlockForConfiguration()
        } catch {
            print("Error setting zoom factor: \(error)")
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
}
