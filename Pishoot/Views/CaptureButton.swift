//
//  CaptureButton.swift
//  Pishoot
//
//  Created by Muhammad Zikrurridho Afwani on 25/06/24.
//

import SwiftUI

struct CaptureButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(Color.white)
                .frame(width: 70, height: 70)
                .overlay(
                    Circle()
                        .stroke(Color.gray, lineWidth: 2)
                        .frame(width: 75, height: 75)
                )
        }
    }
}


#Preview {
    CaptureButton(action: {})
}
