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
            HStack(spacing: AppPadding.extraLarge) {
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
            .padding(.bottom, AppPadding.extraLarge)
            HStack {
                WidgetView(title: "Goal Sport Workout")
                WidgetView(title: "Sport Workout Statistic")
            }
            HStack {
                WidgetView(title: "Active Minutes")
                WidgetView(title: "Calories Burned")
                WidgetView(title: "Steps Taken")
                WidgetView(title: "Rings")
            }
        }
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
