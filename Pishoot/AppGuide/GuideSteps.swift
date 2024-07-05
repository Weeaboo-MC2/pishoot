//
//  GuideSteps.swift
//  Pishoot
//
//  Created by Nadhirul Fatah Ulhaq on 05/07/24.
//

import SwiftUI

let guideSteps: [GuideStep] = [
    GuideStep(id: "Top Control", message: "You can access more to set up by showing what’s in the top control.", highlightFrame: CGRect.zero, arrowPosition: .top, popUpX: UIScreen.main.bounds.width / 2, popUpY: UIScreen.main.bounds.height / 3 - 530, arrowX: UIScreen.main.bounds.width / 2, arrowY: UIScreen.main.bounds.height / 1.5 - 520),
    GuideStep(id: "Position Marker", message: "You can add a marker at the position you want on the camera.", highlightFrame: CGRect.zero, arrowPosition: .bottom, popUpX: UIScreen.main.bounds.width / 2, popUpY: UIScreen.main.bounds.height / 1.5 - 117, arrowX: UIScreen.main.bounds.width / 2 + 33, arrowY: UIScreen.main.bounds.height / 1.5 - 420),
    GuideStep(id: "Set Your Position Marker", message: "Drag and move your position marker based on your preference!", highlightFrame: CGRect.zero, arrowPosition: .top, popUpX: UIScreen.main.bounds.width / 2, popUpY: UIScreen.main.bounds.height / 1.5 - 535, arrowX: UIScreen.main.bounds.width / 2, arrowY: UIScreen.main.bounds.height / 1.5 - 240),
    GuideStep(id: "See Marker on Apple Watch", message: "You already set your dot marker, and now you can see the marker on your Apple Watch.", highlightFrame: CGRect.zero, arrowPosition: .bottom, popUpX: UIScreen.main.bounds.width / 2, popUpY: UIScreen.main.bounds.height / 2, arrowX: UIScreen.main.bounds.width / 2, arrowY: UIScreen.main.bounds.height / 1.5 + 30)
]

#Preview {
    ContentView()
}
