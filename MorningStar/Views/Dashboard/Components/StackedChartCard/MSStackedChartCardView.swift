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
    @ObservedObject private var viewModel: WorkoutStackedChartViewModel
    
    init(workoutHistory: [WeeklyWorkouts]) {
        _viewModel = ObservedObject(wrappedValue: WorkoutStackedChartViewModel(workoutHistory: workoutHistory))
    }
    
    var body: some View {
        Group {
            if viewModel.isEmpty {
                MSStackedChartCardSkeletonView()
            } else {
                VStack(spacing: 0) {
                    HStack(spacing: AppConstants.Spacing.large) {
                        MSImageWithTitle(
                            title: "Workouts",
                            imageName: "workoutIcon"
                        )
                        Spacer()
                        LegendView(color: Color.lowIntensityColor, text: "Low")
                        LegendView(color: Color.moderateIntensityColor, text: "Moderate")
                        LegendView(color: Color.highIntensityColor, text: "High")
                        LegendView(color: Color.veryHighIntensityColor, text: "Very High")
                        LegendView(color: Color.undeterminedIntensityColor, text: "Undetermined")
                    }
                    .padding(AppConstants.Padding.medium)
                    MSStackedChart(viewModel: viewModel)
                }
                .background(Color.trainingColor.opacity(0.5))
                .cornerRadius(AppConstants.Radius.large)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.Radius.large)
                        .stroke(Color.borderColor, lineWidth: 2)
                )
            }
        }
    }
}

#Preview {
    MSStackedChartCardView(workoutHistory: WorkoutMockData.fullHistory)
        .frame(height: 400)
}
