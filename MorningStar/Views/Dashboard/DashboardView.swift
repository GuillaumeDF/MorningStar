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
                // TODO: Reimplenter Total workout this week
//                MSDashboardHeaderMetricView(
//                    title: "Total workout this week",
//                    value: healthData.totalWorkoutHoursThisWeek.minutes == 0 ?
//                    "\(healthData.totalWorkoutHoursThisWeek.hours) hr" : 
//                        "\(healthData.totalWorkoutHoursThisWeek.hours) hr \(healthData.totalWorkoutHoursThisWeek.minutes)"
//                )
                MSVerticalSeparator()
                    .frame(height: 50)
                // TODO: Reimplenter Total step this week
//                MSDashboardHeaderMetricView(
//                    title: "Total step this week",
//                    value: "\(healthData.totalStepThisWeek)"
//                )
            }
            
            GeometryReader { geometry in
                HStack(spacing: 50) {
                    MSLineChartCardView(
                        imageName: "weightIcon",
                        title: "Weight",
                        viewModel: WeightLineChartViewModel(activityPeriods: healthMetrics.weightHistory),
                        backgroundColor: Color.weightColor,
                        arrowDirection: .up
                    )
                    .frame(width: (geometry.size.width - 100) / 3)
                    MSStackedChartCardView(workoutHistory: healthMetrics.workoutHistory)
                }
            }
            
            HStack(spacing: 50) {
                MSLineChartCardView(
                    imageName: "caloriesIcon",
                    title: "Calorie burned",
                    viewModel: ActivityLineChartViewModel(activityPeriods: healthMetrics.calorieBurnedHistory),
                    backgroundColor: Color.calorieColor,
                    arrowDirection: .up
                )
                MSLineChartCardView(
                    imageName: "stepIcon",
                    title: "Step",
                    viewModel: ActivityLineChartViewModel(activityPeriods: healthMetrics.stepCountHistory),
                    backgroundColor: Color.stepColor,
                    arrowDirection: .up
                )
                MSLineChartCardView(
                    imageName: "sleepIcon",
                    title: "Sleep",
                    viewModel: SleepLineChartViewModel(activityPeriods: healthMetrics.sleepHistory),
                    backgroundColor: Color.blue,
                    arrowDirection: .down
                )
            }
        }
    }
}

//#Preview {
//    DashboardView(healthMetrics: .constant(HealthMetrics.empty))
//}
