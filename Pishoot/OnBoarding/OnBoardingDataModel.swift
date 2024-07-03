//
//  OnBoardingDataModel.swift
//  Pishoot
//
//  Created by Nadhirul Fatah Ulhaq on 03/07/24.
//

import Foundation

struct OnBoardingDataModel {
    var imageName: String
    var title: String
    var description: String
    var progress: Float
}

extension OnBoardingDataModel {
    static var data: [OnBoardingDataModel] = [
        OnBoardingDataModel(imageName: "OnBoarding2", title: "Position as you wish", description: "Set custom markers before handing your phone to a stranger. These markers help you position yourself perfectly.", progress: 0.50),
        OnBoardingDataModel(imageName: "OnBoarding3", title: "Triple Zoom Photos", description: "Capture three photos at different zoom levels with a single click. This ensures you get a variety of shots, from wide-angle to close-up, all in one go.", progress: 0.75),
        OnBoardingDataModel(imageName: "OnBoarding4", title: "See Your Apple Watch", description: "Use your Apple Watch to see the markers and adjust your position quickly and easily, without needing to check your phone.", progress: 1.00)
    ]
}
