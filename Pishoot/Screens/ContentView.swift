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
    @State var isAdditionalSettingsOpen: Bool = false
    
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
    
    func toggleAdditionalSettings() {
        isAdditionalSettingsOpen.toggle()
    }
}

#Preview {
    ContentView()
}
