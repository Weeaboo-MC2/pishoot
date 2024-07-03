//
//  OnBoardingContainerView.swift
//  Pishoot
//
//  Created by Nadhirul Fatah Ulhaq on 03/07/24.
//

import SwiftUI

struct OnBoardingContainerView: View {
    @State private var currentStep = 0

    var body: some View {
        VStack {
            if currentStep == 0 {
                WelcomeOnBoarding(onContinue: {
                    currentStep += 1
                })
            } else {
                OnBoardingView(data: OnBoardingDataModel.data[currentStep - 1], isLastStep: currentStep == OnBoardingDataModel.data.count, onBack: {
                    currentStep -= 1
                }, onContinue: {
                    currentStep += 1
                })
            }
        }
        .frame(width: 393, height: 852)
        .background(Color(red: 0.19, green: 0.19, blue: 0.19))
    }
}

struct OnBoardingContainerView_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardingContainerView()
    }
}
