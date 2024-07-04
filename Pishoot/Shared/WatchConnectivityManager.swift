import Foundation
import WatchConnectivity
#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    static let shared = WatchConnectivityManager()
    
    @Published var session: WCSession?
    #if os(iOS)
    @Published var previewImage: UIImage?
    var takePictureOnWatch: (() -> Void)?
    #elseif os(watchOS)
    @Published var previewImage: Data?
    #endif
    
    private var lastSentTime: Date = Date()
    private let minTimeBetweenUpdates: TimeInterval = 0.1
    private var currentQuality: CGFloat = 0.1
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    #if os(iOS)
    func sendPreviewToWatch(_ image: UIImage) {
        guard let session = session, session.isReachable else { return }
        
        let currentTime = Date()
        guard currentTime.timeIntervalSince(lastSentTime) >= minTimeBetweenUpdates else { return }
        
        lastSentTime = currentTime
        DispatchQueue.global(qos: .userInitiated).async {
            if let resizedImage = CameraManager().resizeImage(image, to: CGSize(width: 300, height: 200)),
               let imageData = resizedImage.jpegData(compressionQuality: self.currentQuality) {
                let message = ["previewImage": imageData]
                session.sendMessage(message, replyHandler: nil) { error in
                    print("Error sending preview to watch: \(error.localizedDescription)")
                }
            }
        }
    }
    #endif
    #if os(watchOS)
    func sendTakePictureCommand() {
        guard let session = session, session.isReachable else { return }
        print("Send command to iphone")
        let message = ["command": "takePicture"]
        session.sendMessage(message, replyHandler: nil) { error in
            print("Error sending take picture command: \(error.localizedDescription)")
        }
    }
    #endif
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        DispatchQueue.main.async {
            if let imageData = message["previewImage"] as? Data {
                #if os(iOS)
                self.previewImage = UIImage(data: imageData)
                #elseif os(watchOS)
                self.previewImage = imageData
                #endif
            }
            
            #if os(iOS)
            if let command = message["command"] as? String, command == "takePicture" {
                self.takePictureOnWatch?()
            }
            #endif
        }
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WCSession became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WCSession deactivated")
        WCSession.default.activate()
    }
    #endif
}
