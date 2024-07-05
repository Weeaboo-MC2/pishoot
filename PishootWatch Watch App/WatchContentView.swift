import SwiftUI

struct WatchContentView: View {
    @ObservedObject var connectivityManager = WatchConnectivityManager.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var isActive = true
    
    var body: some View {
        VStack {
            //            Text("isIosAppReachable \(connectivityManager.isIOSAppReachable)")
            //            Text("is Active \(isActive)")
            //
            
            ZStack {
                if isActive {
                    if connectivityManager.isIOSAppReachable {
                        if let imageData = connectivityManager.previewImage,
                           let uiImage = UIImage(data: imageData) {
                            let screenSize = WKInterfaceDevice.current().screenBounds.size
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenSize.height, height: screenSize.width)
                                .clipped()
                                .rotationEffect(Angle(degrees: 90))
                                .position(x: screenSize.width / 2, y: screenSize.height / 2)
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
                                .padding()
                        }
                    } else {
                        Text("iOS app not open")
                    }
                } else if !isActive && connectivityManager.isIOSAppReachable{
                    Color.black.edgesIgnoringSafeArea(.all)
                    Text("Inactive")
                        .foregroundColor(.white)
                }
            }
            .edgesIgnoringSafeArea(.all)
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
