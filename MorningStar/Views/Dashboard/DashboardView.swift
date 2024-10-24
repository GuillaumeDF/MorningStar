//
//  DashboardView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 06/08/2024.
//

import SwiftUI

struct DashboardView: View {
    @Binding var healthData: HealthData
    
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
                    value: healthData.totalWorkoutHoursThisWeek.minutes == 0 ?
                    "\(healthData.totalWorkoutHoursThisWeek.hours) hr" : 
                        "\(healthData.totalWorkoutHoursThisWeek.hours) hr \(healthData.totalWorkoutHoursThisWeek.minutes)"
                )
                MSVerticalSeparator()
                    .frame(height: 50)
                MSDashboardHeaderMetricView(
                    title: "Total step this week",
                    value: "\(healthData.totalStepThisWeek)"
                )
            }
            
            GeometryReader { geometry in
                HStack(spacing: 50) {
                    MSLineChartCardView(
                        imageName: "weightIcon",
                        title: "Weight",
                        viewModel: WeightLineChartViewModel(activityPeriods: healthData.weightHistory),
                        backgroundColor: Color.weightColor,
                        arrowDirection: .up
                    )
                    .frame(width: (geometry.size.width - 100) / 3)
                    MSStackedChartCardView(workoutHistory: healthData.workoutHistory)
                }
            }
            
            HStack(spacing: 50) {
                MSLineChartCardView(
                    imageName: "caloriesIcon",
                    title: "Calorie burned",
                    viewModel: ActivityLineChartViewModel(activityPeriods: healthData.calorieBurnHistory),
                    backgroundColor: Color.calorieColor,
                    arrowDirection: .up
                )
                MSLineChartCardView(
                    imageName: "stepIcon",
                    title: "Step",
                    viewModel: ActivityLineChartViewModel(activityPeriods: healthData.stepCountHistory),
                    backgroundColor: Color.stepColor,
                    arrowDirection: .up
                )
                MSLineChartCardView(
                    imageName: "sleepIcon",
                    title: "Sleep",
                    viewModel: SleepLineChartViewModel(activityPeriods: healthData.sleepHistory),
                    backgroundColor: Color.blue,
                    arrowDirection: .down
                )
            }
        }
    }
}

#Preview {
    DashboardView(healthData: .constant(HealthData()))
}
