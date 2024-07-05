//
//  ContentView.swift
//  Pishoot
//
//  Created by Muhammad Zikrurridho Afwani on 25/06/24.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var lastPhotos: [UIImage] = []
    @State var isMarkerOn: Bool = false
    @State var isAdditionalSettingsOpen: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var showGuide = UserDefaults.standard.bool(forKey: "hasSeenGuide") == false
    @State private var highlightFrame = CGRect.zero
    @State private var guideStepIndex = 0
    @State private var chevronButtonTapped = false
    
    @State var animationProgress: CGFloat = 0
    var body: some View {
        VStack {
            TopBarView(isAdditionalSettingsOpen: $isAdditionalSettingsOpen)
                .padding(.bottom, 5)
            
            if let session = cameraViewModel.session {
                ZStack {
                    CameraPreviewView(session: session, countdown: $cameraViewModel.countdown)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 16 / 9)
                        .clipped()
                        .overlay(
                            BlackScreenView(animationProgress: $animationProgress)
                                .opacity(cameraViewModel.isBlackScreenVisible ? 1 : 0)
                        )
                    
                    VStack {
                        Spacer()
                        
                        if isAdditionalSettingsOpen {
                            MainAdditionalSetting(selectedZoomLevel: $cameraViewModel.selectedZoomLevel, isMarkerOn: $isMarkerOn, toggleFlash: {
                                cameraViewModel.toggleFlash()
                            }, isFlashOn: cameraViewModel.isFlashOn, cameraViewModel: cameraViewModel)
                        }
                        
                        BottomBarView(lastPhoto: lastPhotos.first, captureAction: {
                            cameraViewModel.capturePhotos { images in
                                self.lastPhotos = images
                            }
                        }, openPhotosApp: {
                            PhotoLibraryHelper.openPhotosApp()
                        },
                                      isCapturing: $cameraViewModel.isCapturingPhoto,animationProgress: $animationProgress
                        )
                        .padding(.bottom, 5)
                    }
                    Marker(isMarkerOn: $isMarkerOn)
                    if showGuide {
                        ZStack {
                            GuideView(isPresented: $showGuide, isAdditionalSettingsOpen: $isAdditionalSettingsOpen, isMarkerOn: $isMarkerOn, steps: guideSteps)
                                .onPreferenceChange(HighlightFrameKey.self) { value in
                                    self.highlightFrame = value
                                }
                        }
                    }
                }
            } else {
                Text("Camera not available")
            }
            
        }
        .statusBar(hidden: true)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(newPhase)
        }
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
