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

    var body: some View {
        VStack {
            TopBarView(toggleAdditionalSettings: cameraViewModel.toggleAdditionalSettings,
                       isAdditionalSettingsOpen: cameraViewModel.isAdditionalSettingsOpen)
            .padding(.top, 40)
            .padding(.horizontal)
            
            if let session = cameraViewModel.session {
                ZStack {
                    CameraPreviewView(session: session)
                        .edgesIgnoringSafeArea(.all)
                        .overlay(
                            BlackScreenView(progress: $cameraViewModel.captureProgress)
                                .opacity(cameraViewModel.isBlackScreenVisible ? 1 : 0)
                        )

                    VStack {
                        Spacer()
                        
                        if cameraViewModel.isAdditionalSettingsOpen {
                            MainAdditionalSetting(selectedZoomLevel: $cameraViewModel.selectedZoomLevel, toggleFlash: {
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
                            isCapturing: $cameraViewModel.isCapturingPhoto
                        )
                        .padding(.bottom, 20)
                    }
                }
            } else {
                Text("Camera not available")
            }
        }
        .onAppear {
            cameraViewModel.startSession()
            PhotoLibraryHelper.fetchLastPhoto { image in
                if let image = image {
                    self.lastPhotos = [image]
                }
            }
        }
        .onDisappear {
            cameraViewModel.stopSession()
        }
        .statusBar(hidden: true)
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}
