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
                        valeur: "75",
                        unity: "kg",
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
                    valeur: "500",
                    unity: "kcal",
                    arrowDirection: .up,
                    backgroundColor: Color.calorieColor
                )
                MSLineChartCardView(
                    imageName: "stepIcon",
                    title: "Step",
                    valeur: "10 000",
                    unity: "step",
                    arrowDirection: .up,
                    backgroundColor: Color.stepColor
                )
                MSLineChartCardView(
                    imageName: "sleepIcon",
                    title: "Sleep",
                    valeur: "10",
                    unity: "h",
                    arrowDirection: .down,
                    backgroundColor: Color.blue
                )
            }
        }
    }
}

#Preview {
    DashboardView(healthData: .constant(HealthData()))
}
