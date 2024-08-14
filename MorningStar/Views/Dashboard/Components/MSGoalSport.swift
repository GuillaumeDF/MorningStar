//
//  MSGoalSport.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 13/08/2024.
//

import SwiftUI

struct MSGoalSport: View {
    @State private var progress: Double = 0.5
    
    var body: some View {
        MSLabeledContainer(title: "Goal", content: {
            VStack(spacing: AppConstants.Padding.large) {
                MSAvatarProgressView(title: "Pas", imageName: "stepIcon", progress: $progress)
                MSAvatarProgressView(title: "Calorie", imageName: "caloriesIcon", progress: $progress)
                MSAvatarProgressView(title: "Poids", imageName: "weightIcon", progress: $progress)
            }
            .padding(AppConstants.Padding.large)
            .background(Color.cardBackgroundColor)
            .cornerRadius(AppConstants.Radius.large)
        })
    }
}

#Preview {
    MSGoalSport()
}

