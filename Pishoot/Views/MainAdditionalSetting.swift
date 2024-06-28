//
//  MainAdditionalSetting.swift
//  Pishoot
//
//  Created by Muhammad Zikrurridho Afwani on 26/06/24.
//

import SwiftUI

struct MainAdditionalSetting: View {
    var body: some View {
        HStack (spacing: 30) {
            Button(action: {}) {
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
}

#Preview {
    MainAdditionalSetting()
}
