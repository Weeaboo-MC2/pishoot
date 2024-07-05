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
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 4)
                        
                        Rectangle()
                            .fill(Color("pishootYellow"))
                            .frame(width: geometry.size.width * progress, height: 4)
                            .animation(.linear, value: progress)
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.7, height: 4)
            }
        }
    }
}

#Preview {
    BlackScreenView(progress: .constant(0.5))
}
