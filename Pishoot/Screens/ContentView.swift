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

    var body: some View {
        ZStack {
            CameraPreviewView(session: cameraViewModel.session)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    VStack {
                        TopBarView(toggleFlash: {
                            cameraViewModel.toggleFlash()
                        }, isFlashOn: cameraViewModel.isFlashOn)
                        
                        Spacer()
                        
                        BottomBarView(lastPhoto: lastPhoto, captureAction: {
                            cameraViewModel.capturePhotos { image in
                                self.lastPhoto = image
                            }
                        }, openPhotosApp: {
                            PhotoLibraryHelper.openPhotosApp()
                        })
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
    }
}

#Preview {
    ContentView()
}
