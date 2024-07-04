import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var lastPhotos: [UIImage] = []
    @State var isAdditionalSettingsOpen: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        VStack {
            TopBarView(toggleFlash: {
                cameraViewModel.toggleFlash()
            }, toggleAdditionalSettings: toggleAdditionalSettings, isFlashOn: cameraViewModel.isFlashOn,
                       isAdditionalSettingsOpen: isAdditionalSettingsOpen)
            .padding(.top, 40)
            .padding(.horizontal)
            
            if let session = cameraViewModel.cameraManager.session {
                CameraPreviewView(session: session)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        VStack {
                            Spacer()
                            
                            if isAdditionalSettingsOpen {
                                MainAdditionalSetting()
                            }
                            
                            BottomBarView(lastPhoto: lastPhotos.first, captureAction: {
                                cameraViewModel.capturePhotos { images in
                                    self.lastPhotos = images
                                }
                            }, openPhotosApp: {
                                PhotoLibraryHelper.openPhotosApp()
                            })
                            .padding(.bottom, 20)
                        }
                    )
            } else {
                Text("Camera not available")
            }
        }
        .statusBar(hidden: true)
        .ignoresSafeArea()
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(newPhase)
        }
    }
    
    func toggleAdditionalSettings() {
        isAdditionalSettingsOpen.toggle()
    }
    
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            print("App became active")
            cameraViewModel.startSession()
            PhotoLibraryHelper.fetchLastPhoto { image in
                if let image = image {
                    self.lastPhotos = [image]
                }
            }
        case .inactive:
            print("App became inactive")
        case .background:
            print("App went to background")
            cameraViewModel.stopSession()
        @unknown default:
            print("Unknown scene phase")
        }
    }
}

#Preview {
    ContentView()
}
