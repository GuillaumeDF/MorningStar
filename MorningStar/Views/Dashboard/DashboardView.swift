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
        if !healthData.stepCountHistory.isEmpty && !healthData.calorieBurnHistory.isEmpty && !healthData.weightHistory.isEmpty {
            
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
                        value: "3457 hours"
                    )
                    MSVerticalSeparator()
                        .frame(height: 50)
                    MSNewActivityButton()
                }
                
                GeometryReader { geometry in
                    HStack(spacing: 50) {
                        MSLineChartCardView(
                            imageName: "weightIcon",
                            title: "Weight",
                            dailyActivities: healthData.weightHistory,
                            arrowDirection: .up,
                            backgroundColor: Color.weightColor
                        )
                        .frame(width: (geometry.size.width - 100) / 3)
                        MSStackedChartCardView()
                    }
                }
                
                HStack(spacing: 50) {
                    MSLineChartCardView(
                        imageName: "caloriesIcon",
                        title: "Calorie burned",
                        dailyActivities: healthData.calorieBurnHistory,
                        arrowDirection: .up,
                        backgroundColor: Color.calorieColor
                    )
                    MSLineChartCardView(
                        imageName: "stepIcon",
                        title: "Step",
                        dailyActivities: healthData.stepCountHistory,
                        arrowDirection: .up,
                        backgroundColor: Color.stepColor
                    )
                    MSLineChartCardView(
                        imageName: "sleepIcon",
                        title: "Sleep",
                        dailyActivities: healthData.stepCountHistory,
                        arrowDirection: .down,
                        backgroundColor: Color.blue
                    )
                }
            }
        }
    }
}

#Preview {
    DashboardView(healthData: .constant(HealthData()))
}
