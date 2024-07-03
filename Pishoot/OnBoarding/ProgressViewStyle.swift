//
//  ProgressViewStyle.swift
//  Pishoot
//
//  Created by Nadhirul Fatah Ulhaq on 03/07/24.
//

import SwiftUI

struct CustomLinearProgressViewStyle: ProgressViewStyle {
    var trackColor: Color
    var progressColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .foregroundColor(trackColor)
                .frame(height: 5)
            
            Rectangle()
                .foregroundColor(progressColor)
                .frame(width: CGFloat(configuration.fractionCompleted ?? 0) * 200, height: 5)
        }
        .cornerRadius(5)
    }
}
