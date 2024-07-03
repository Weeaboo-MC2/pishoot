//
//  BlackScreenView.swift
//  Pishoot
//
//  Created by Muhammad Zikrurridho Afwani on 03/07/24.
//

import SwiftUI

struct BlackScreenView: View {
    @Binding var progress: CGFloat

    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Hold Still")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 10)

                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)

                    Rectangle()
                        .fill(Color.yellow)
                        .frame(width: UIScreen.main.bounds.width * progress, height: 4)
                }
                .frame(width: UIScreen.main.bounds.width * 0.7)
            }
        }
    }
}

#Preview {
    BlackScreenView(progress: .constant(0.5))
}
