//
//  MSStackedChartCardView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/08/2024.
//

import SwiftUI

private enum Constants {
    static let imageHeight: CGFloat = 25
}

struct IntensitySegment: Hashable {
    var time: CGFloat
    var type: IntensityLevel
}

struct MSStackedChartCardView: View {
    let workoutHistory: HealthData.WorkoutHistory
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: AppConstants.Spacing.large) {
                MSRoundImageWithTitle(
                    title: "Workouts with Intense Phases",
                    imageName: "workoutIcon"
                )
                Spacer()
                LegendView(color: Color.lowIntensity, text: "Low")
                LegendView(color: Color.moderateIntensity, text: "Moderate")
                LegendView(color: Color.highIntensity, text: "High")
                LegendView(color: Color.veryHighIntensity, text: "Very High")
            }
            .padding(AppConstants.Padding.medium)
            MSStackedChart(viewModel: WorkoutStackedChartViewModel(workoutHistory: workoutHistory))
        }
        .background(Color.trainingColor.opacity(0.5))
        .cornerRadius(AppConstants.Radius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.Radius.large)
                .stroke(Color.borderColor, lineWidth: 2)
        )
    }
}

//#Preview {
//    MSStackedChartCardView()
//        .frame(height: 500)
//}
