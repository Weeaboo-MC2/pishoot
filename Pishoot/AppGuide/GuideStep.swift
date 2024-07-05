//
//  GuideStep.swift
//  Pishoot
//
//  Created by Nadhirul Fatah Ulhaq on 04/07/24.
//

import SwiftUI

enum ArrowPosition {
    case top
    case bottom
}

struct GuideStep {
    let id: String
    let message: String
    let highlightFrame: CGRect
    let arrowPosition: ArrowPosition
    let popUpX: CGFloat
    let popUpY: CGFloat
    let arrowX: CGFloat
    let arrowY: CGFloat
}
