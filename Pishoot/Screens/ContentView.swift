//
//  ContentView.swift
//  Pishoot
//
//  Created by Muhammad Zikrurridho Afwani on 25/06/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var lastPhoto: UIImage? = nil
    @State var isAdditionalSettingsOpen: Bool = false

    var body: some View {
        VStack {
            TopBarView(toggleFlash: {
                cameraViewModel.toggleFlash()
            }, toggleAdditionalSettings: toggleAdditionalSettings, isFlashOn: cameraViewModel.isFlashOn,
                       isAdditionalSettingsOpen: isAdditionalSettingsOpen)
            .padding(.top, 40)
            .padding(.horizontal)
            
            CameraPreviewView(session: cameraViewModel.session)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    VStack {
                        
                        Spacer()
                        
                        BottomBarView(lastPhoto: lastPhoto, captureAction: {
                            cameraViewModel.capturePhotos { image in
                                self.lastPhoto = image
                            }
                        }, openPhotosApp: {
                            PhotoLibraryHelper.openPhotosApp()
                        })
                        .padding(.bottom, 20)
                    }
                )
        }
        .onAppear {
            cameraViewModel.startSession()
            PhotoLibraryHelper.fetchLastPhoto { image in
                self.lastPhoto = image
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
