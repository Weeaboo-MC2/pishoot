//
//  TopBarView.swift
//  Pishoot
//
//  Created by Muhammad Zikrurridho Afwani on 25/06/24.
//

import SwiftUI

struct TopBarView: View {
    var toggleAdditionalSettings: () -> Void
    var isAdditionalSettingsOpen: Bool
    
    var body: some View {
        HStack {
            Button(action: {
                withAnimation() {
                    toggleAdditionalSettings()
                }
            }) {
                Image(systemName: isAdditionalSettingsOpen ? "chevron.down" : "chevron.up")
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color.gray.opacity(0.5))
                    .clipShape(Circle())
            }
        }
    }
}


#Preview {
    TopBarView(toggleAdditionalSettings: {}, isAdditionalSettingsOpen: false)
}
