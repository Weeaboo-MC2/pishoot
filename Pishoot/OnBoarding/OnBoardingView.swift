//
//  OnBoardingView.swift
//  Pishoot
//
//  Created by Nadhirul Fatah Ulhaq on 03/07/24.
//

import SwiftUI

struct OnBoardingView: View {
    var data: OnBoardingDataModel
    var isLastStep: Bool
    var onBack: () -> Void
    var onContinue: () -> Void

    var body: some View {
        VStack {
            ZStack {
                VStack {
                    Spacer()
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        
                        .background(
                            Image(data.imageName)
                                .resizable()
                                .scaledToFill()
                                .clipped()
                        )
                }
                .frame(width: 393, height: 444)
                .background(Color(red: 0.95, green: 0.86, blue: 0.04))
            }
            .frame(width: 393, height: 444)
            
            VStack(alignment: .leading, spacing: 38) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(data.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    Text(data.description)
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .padding(0)
                .frame(width: 299.5, alignment: .topLeading)
                
                ProgressView(value: data.progress)
                    .progressViewStyle(CustomLinearProgressViewStyle(
                        trackColor: Color(red: 0.8, green: 0.8, blue: 0.8),
                        progressColor: Color(red: 0.84, green: 0.81, blue: 0)
                    ))
                    .frame(width: 200, height: 5)
                
                HStack(alignment: .center, spacing: 3) {
                    if !isLastStep {
                        VStack(alignment: .center, spacing: 10) {
                            Text("Back")
                                .font(.body)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color(red: 0.95, green: 0.86, blue: 0.04))
                                .onTapGesture {
                                    onBack()
                                }
                        }
                        .padding(10)
                        .frame(width: 103, alignment: .center)
                        .cornerRadius(9)
                    }
                    
                    VStack(alignment: .center, spacing: 10) {
                        Text(isLastStep ? "Get Started" : "Continue")
                            .font(.body)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .onTapGesture {
                                onContinue()
                            }
                    }
                    .padding(10)
                    .frame(width: isLastStep ? 310 : 207, alignment: .center)
                    .background(Color(red: 0.95, green: 0.86, blue: 0.04))
                    .cornerRadius(9)
                }
                .padding(0)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 37)
            .frame(width: 313, alignment: .topLeading)
            
            Spacer()
        }
        .frame(width: 393, height: 852)
        .background(Color(red: 0.19, green: 0.19, blue: 0.19))
    }
}

#Preview {
        OnBoardingView(data: OnBoardingDataModel.data[0], isLastStep: false, onBack: {}, onContinue: {})
}
