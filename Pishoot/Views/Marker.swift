//
//  Marker.swift
//  Pishoot
//
//  Created by Gerry Chandra on 04/07/24.
//

import SwiftUI

struct Marker: View {
    @State var position: CGPoint = CGPoint(x: 393.0/2, y:  852.0/2)
    @Binding var isMarkerOn: Bool
    
    var body: some View {
        ZStack {
            if isMarkerOn {
                Image(systemName: "target")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .position(position)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                position = value.location
                            }
                    )
            }
        }
        .onAppear{
            let iPhoneScreenSize = UIScreen.main.bounds.size
            position = CGPoint(x: iPhoneScreenSize.width/2, y: iPhoneScreenSize.height/2)
        }
    }
}

#Preview {
    Marker(isMarkerOn: .constant(false))
}
