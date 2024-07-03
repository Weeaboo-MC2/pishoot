import SwiftUI

struct WatchContentView: View {
    @ObservedObject var connectivityManager = WatchConnectivityManager.shared
    
    var body: some View {
        VStack {
            if let imageData = connectivityManager.previewImage,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .rotationEffect(Angle(degrees: 90))
            } else {
                Text("Waiting for preview...")
            }
            
//            Button(action: {
//                connectivityManager.sendTakePictureCommand()
//            }) {
//                
//            }
        }
        .onAppear {
            // Any setup code when the view appears
        }
        .onDisappear {
            // Any cleanup code when the view disappears
        }
    }
}

struct WatchContentView_Previews: PreviewProvider {
    static var previews: some View {
        WatchContentView()
    }
}
