//
//  MainAdditionalSetting.swift
//  Pishoot
//
//  Created by Muhammad Zikrurridho Afwani on 26/06/24.
//

import SwiftUI

struct MainAdditionalSetting: View {
    @Binding var isZoomOptionsVisible: Bool
    @Binding var selectedZoomLevel: CGFloat
    var cameraViewModel: CameraViewModel

    var body: some View {
        VStack {
           if !isZoomOptionsVisible {
               HStack (spacing: 30) {
                   Button(action: {
                       withAnimation() {
                           isZoomOptionsVisible.toggle()
                       }
                   }) {
                       Image(systemName: "plus.magnifyingglass")
                           .foregroundColor(.white)
                           .padding(10)
                           .background(Color.black.opacity(0.5))
                           .clipShape(Circle())
                   }
                   Button(action: {}) {
                       Image(systemName: "target")
                           .foregroundColor(.white)
                           .padding(10)
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
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Button(action: {
                        selectedZoomLevel = 1.0
                        cameraViewModel.setZoomLevel(zoomLevel: selectedZoomLevel)
                    }) {
                        Text("1x")
                            .foregroundColor(selectedZoomLevel == 1.0 ? .yellow : .white)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    Button(action: {
                        selectedZoomLevel = 2.0
                        cameraViewModel.setZoomLevel(zoomLevel: selectedZoomLevel)
                    }) {
                        Text("2x")
                            .foregroundColor(selectedZoomLevel == 2.0 ? .yellow : .white)
                            .padding(10)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(5)
                .background(Color.black.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
    }
}


#Preview {
    MainAdditionalSetting(isZoomOptionsVisible: .constant(true), selectedZoomLevel: Binding<CGFloat>(get: { 1.0 }, set: { _ in }), cameraViewModel: CameraViewModel())
}
