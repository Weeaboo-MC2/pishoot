import SwiftUI

struct WatchContentView: View {
    @ObservedObject var connectivityManager = WatchConnectivityManager.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var isActive = true
    
    var body: some View {
        VStack {
            ZStack {
                if isActive {
                    if connectivityManager.isIOSAppReachable {
                        if let imageData = connectivityManager.previewImage,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .rotationEffect(Angle(degrees: 90))
                        } else {
                            Text("Waiting for preview...")
                        }
                        VStack {
                            Spacer()
                            Button(action: {
                                print("Take picture button pressed")
                                connectivityManager.sendTakePictureCommand()
                            }) {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray, lineWidth: 1)
                                            .frame(width: 30, height: 30)
                                    )
                            }.buttonStyle(PlainButtonStyle())
                        }
                    } else {
                        Text("iOS app not open")
                    }
                } else {
                    Color.black.edgesIgnoringSafeArea(.all)
                    Text("Inactive")
                        .foregroundColor(.white)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .active:
                isActive = true
                connectivityManager.updateIOSAppReachability()
            case .inactive, .background:
                isActive = false
            @unknown default:
                break
            }
        }
    }
}
