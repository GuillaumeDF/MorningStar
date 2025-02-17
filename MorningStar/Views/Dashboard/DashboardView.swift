//
//  DashboardView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 06/08/2024.
//

import SwiftUI

struct DashboardView: View {
    @Binding var healthMetrics: HealthMetrics
    
    var body: some View {
        VStack(spacing: AppConstants.Padding.extraLarge) {
            
            HStack(spacing: AppConstants.Padding.extraLarge) {
                VStack(alignment: .leading) {
                    Text("My Analytics")
                        .font(.title)
                        .foregroundStyle(Color.primaryTextColor)
                    Text("Information designed to accurate insights")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryTextColor)
                }
                Spacer()
                MSDashboardHeaderMetricView(
                    title: "Total workout this week",
                    value: healthMetrics.totalWorkoutHoursThisWeek
                )
                MSVerticalSeparator()
                    .frame(height: 50)
                MSDashboardHeaderMetricView(
                    title: "Total step this week",
                    value: "\(healthMetrics.totalStepThisWeek)"
                )
            }
            
            GeometryReader { geometry in
                HStack(spacing: 50) {
                    MSLineChartCardView(
                        imageName: "weightIcon",
                        title: "Weight",
                        viewModel: WeightLineChartViewModel(activityPeriods: healthMetrics.weightHistory),
                        backgroundColor: HealthMetricType.weight.color,
                        arrowDirection: .up
                    )
                    .frame(width: (geometry.size.width - 100) / 3)
                    MSStackedChartCardView(
                        workoutHistory: healthMetrics.workoutHistory
                    )
                }
            }
            
            HStack(spacing: 50) {
                MSLineChartCardView(
                    imageName: "caloriesIcon",
                    title: "Calorie burned",
                    viewModel: ActivityLineChartViewModel(activityPeriods: healthMetrics.calorieBurnedHistory),
                    backgroundColor: HealthMetricType.calories.color,
                    arrowDirection: .up
                )
                MSLineChartCardView(
                    imageName: "stepIcon",
                    title: "Step",
                    viewModel: ActivityLineChartViewModel(activityPeriods: healthMetrics.stepCountHistory),
                    backgroundColor: HealthMetricType.steps.color,
                    arrowDirection: .up
                )
                MSLineChartCardView(
                    imageName: "sleepIcon",
                    title: "Sleep",
                    viewModel: SleepLineChartViewModel(activityPeriods: healthMetrics.sleepHistory),
                    backgroundColor: HealthMetricType.sleep.color,
                    arrowDirection: .down
                )
            }
        }
    }
}

//#Preview {
//    DashboardView(healthMetrics: .constant(HealthMetrics.empty))
//}
