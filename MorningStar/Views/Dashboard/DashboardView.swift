//
//  DashboardView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 06/08/2024.
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        VStack {
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
                MSDashboardHeaderMetricView(
                    title: "Heart rate",
                    value: "90 bpm"
                )
                MSNewActivityButton()
            }
            .padding(.bottom, AppConstants.Padding.extraLarge)
            HStack(spacing: 50) {
                MSMetricChart(
                    imageName: "weightIcon",
                    title: "Weight",
                    valeur: "75",
                    unity: "kg",
                    arrowDirection: .up,
                    backgroundColor: Color.weightColor
                )
                .frame(height: 400)
                WorkoutIntensityView()
                    .frame(width: 800, height: 400)
            }
            HStack(spacing: 50) {
                MSMetricChart(
                    imageName: "caloriesIcon",
                    title: "Calorie burned",
                    valeur: "500",
                    unity: "kcal",
                    arrowDirection: .up,
                    backgroundColor: Color.calorieColor
                )
                .frame(height: 400)
                MSMetricChart(
                    imageName: "stepIcon",
                    title: "Step",
                    valeur: "10 000",
                    unity: "step",
                    arrowDirection: .up,
                    backgroundColor: Color.stepColor
                )
                .frame(height: 400)
                MSMetricChart(
                    imageName: "weightIcon",
                    title: "Sleep",
                    valeur: "10",
                    unity: "h",
                    arrowDirection: .down,
                    backgroundColor: Color.blue
                )
                .frame(height: 400)
            }
        }
    }
}

#Preview {
    DashboardView()
}
