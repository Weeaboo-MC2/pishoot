import Foundation
import WatchConnectivity

class WatchViewModel: ObservableObject {
    @Published var previewImageData: Data?
    
    let connectivityManager = WatchConnectivityManager.shared
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Subscribe to changes in preview image data from WatchConnectivityManager
        connectivityManager.$previewImage.sink { [weak self] imageData in
            self?.previewImageData = imageData
        }
    }
    
    func sendTakePictureCommand() {
        connectivityManager.sendTakePictureCommand()
    }
}
