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
            HStack {
                MSGoalSport()
                    .frame(width: 400)
                WorkoutIntensityView()
                .frame(height: 400)
            }
            HStack {
                MSActivityChart()
                MSCaloriesChart()
                MSStepsChart()
                MSRingsChart()
            }
        }
    }
}

struct StackedBarChart: View {
    var data: [[Double]]
    var colors: [Color]
    var labels: [String]

    var body: some View {
        HStack(alignment: .bottom, spacing: 16) {
            ForEach(0..<data.count, id: \.self) { index in
                VStack {
                    Spacer()

                    ForEach(0..<data[index].count, id: \.self) { subIndex in
                        Rectangle()
                            .fill(colors[subIndex])
                            .frame(height: CGFloat(data[index][subIndex]))
                    }
                }
                .frame(width: 40)
                .overlay(
                    Text(labels[index])
                        .font(.caption)
                        .padding(.top, 8),
                    alignment: .top
                )
            }
        }
        .padding()
    }
}

struct WidgetView: View {
    let title: String
    
    var body: some View {
        Rectangle()
            .fill(Color.cardBackgroundColor)
            .frame(height: 100)
            .overlay(
                Text(title)
                    .foregroundColor(.primaryTextColor)
                    .font(.headline)
            )
            .cornerRadius(10)
    }
}

#Preview {
    DashboardView()
}
