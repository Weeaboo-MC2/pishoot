//
//  TopBarView.swift
//  Pishoot
//
//  Created by Muhammad Zikrurridho Afwani on 25/06/24.
//

import SwiftUI

struct TopBarView: View {
    var toggleFlash: () -> Void
    var isFlashOn: Bool
    
    var body: some View {
        ZStack {
            HStack {
                Button(action: {
                    toggleFlash()
                }) {
                    Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                }
                
                Spacer()
            }
            
            Button(action: {
                // Arrow action (next)
            }) {
                Image(systemName: "chevron.up")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.gray.opacity(0.5))
                    .clipShape(Circle())
            }
        }
        .padding()
    }
}


#Preview {
    TopBarView(toggleFlash: {}, isFlashOn: false)
}
