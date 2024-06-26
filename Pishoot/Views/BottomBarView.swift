//
//  BottomBarView.swift
//  Pishoot
//
//  Created by Muhammad Zikrurridho Afwani on 25/06/24.
//

import SwiftUI

struct BottomBarView: View {
    var lastPhoto: UIImage?
    var captureAction: () -> Void
    var openPhotosApp: () -> Void

    var body: some View {
        ZStack {
            HStack(alignment: .center) {
                PhotoThumbnailView(lastPhoto: lastPhoto, openPhotosApp: openPhotosApp)
                Spacer()
            }
            .padding()
            .padding(.bottom)
            
            HStack {
                Spacer()
                CaptureButton(action: captureAction)
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}


#Preview {
    BottomBarView(lastPhoto: nil, captureAction: {}, openPhotosApp: {})
}
