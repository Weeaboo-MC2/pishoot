import SwiftUI

class CameraViewModel: ObservableObject {
    @Published var isFlashOn = false
    @Published var lastPhotos: [UIImage] = []
    
    let cameraManager = CameraManager()
    
    init() {
        setupBindings()
        WatchConnectivityManager.shared.takePictureOnWatch = { [weak self] in
            self?.capturePhotos { images in
                // Handle the captured images if needed
            }
        }
    }
    
    private func setupBindings() {
        cameraManager.isFlashOn = isFlashOn
    }
    
    func startSession() {
        cameraManager.startSession()
    }
    
    func stopSession() {
        cameraManager.stopSession()
    }
    
    func toggleFlash() {
        isFlashOn.toggle()
        cameraManager.toggleFlash()
    }
    
    func capturePhotos(completion: @escaping ([UIImage]) -> Void) {
        cameraManager.capturePhotos { [weak self] images in
            self?.lastPhotos = images
            completion(images)
        }
    }
}
