//
//  MainAdditionalSetting.swift
//  Pishoot
//
//  Created by Muhammad Zikrurridho Afwani on 26/06/24.
//

import SwiftUI

struct MainAdditionalSetting: View {
    @State private var isZoomOptionsVisible: Bool = false
    @State private var isTimerOptionsVisible: Bool = false
    @Binding var selectedZoomLevel: CGFloat
    var toggleFlash: () -> Void
    var isFlashOn: Bool
    var cameraViewModel: CameraViewModel
    
    var body: some View {
        VStack {
            if !isZoomOptionsVisible && !isTimerOptionsVisible {
                HStack (spacing: 25) {
                    Button(action: {
                        withAnimation {
                            toggleFlash()
                        }
                    }) {
                        Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                            .frame(width: 40, height: 40)
                            .foregroundColor(isFlashOn ? .yellow : .white)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Button(action: {
                        withAnimation() {
                            isZoomOptionsVisible.toggle()
                        }
                    }) {
                        Image(systemName: "plus.magnifyingglass")
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Button(action: {}) {
                        Image(systemName: "target")
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Button(action: {
                        withAnimation() {
                            isTimerOptionsVisible.toggle()
                        }
                    }) {
                        Image(systemName: "timer")
                            .foregroundColor(cameraViewModel.timerDuration == 0 ? .white : .yellow)
                            .frame(width: 40, height: 40)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
            }
            
            if isZoomOptionsVisible {
                HStack(spacing: 20) {
                    Button(action: {
                        withAnimation(.spring()) {
                            isZoomOptionsVisible.toggle()
                        }
                    }) {
                        Image(systemName: "plus.magnifyingglass")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Button(action: {
                        selectedZoomLevel = 0.5
                        cameraViewModel.setZoomLevel(zoomLevel: selectedZoomLevel)
                    }) {
                        Text("0.5x")
                            .foregroundColor(selectedZoomLevel == 0.5 ? .yellow : .white)
                            .padding(10)
                    }
                    Button(action: {
                        selectedZoomLevel = 1.0
                        cameraViewModel.setZoomLevel(zoomLevel: selectedZoomLevel)
                    }) {
                        Text("1x")
                            .foregroundColor(selectedZoomLevel == 1.0 ? .yellow : .white)
                            .padding(10)
                    }
                    Button(action: {
                        selectedZoomLevel = 2.0
                        cameraViewModel.setZoomLevel(zoomLevel: selectedZoomLevel)
                    }) {
                        Text("2x")
                            .foregroundColor(selectedZoomLevel == 2.0 ? .yellow : .white)
                            .padding(10)
                    }
                }
                .background(Color.black.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        
        if isTimerOptionsVisible {
            HStack(spacing: 20) {
                Button(action: {
                    withAnimation(.spring()) {
                        isTimerOptionsVisible.toggle()
                    }
                }) {
                    Image(systemName: "timer")
                        .foregroundColor(cameraViewModel.timerDuration == 0 ? .white : .yellow)
                        .padding(10)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                Button(action: {
                    cameraViewModel.timerDuration = 3
                }) {
                    Text("3s")
                        .foregroundColor(cameraViewModel.timerDuration == 3 ? .yellow : .white)
                        .padding(10)
                }
                Button(action: {
                    cameraViewModel.timerDuration = 10
                }) {
                    Text("10s")
                        .foregroundColor(cameraViewModel.timerDuration == 10 ? .yellow : .white)
                        .padding(10)
                }
                Button(action: {
                    cameraViewModel.timerDuration = 0
                }) {
                    Text("Off")
                        .foregroundColor(cameraViewModel.timerDuration == 0 ? .yellow : .white)
                        .padding(10)
                }
            }
            .background(Color.black.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}


#Preview {
    MainAdditionalSetting(selectedZoomLevel: Binding<CGFloat>(get: { 1.0 }, set: { _ in }), toggleFlash: {}, isFlashOn: true, cameraViewModel: CameraViewModel())
}
