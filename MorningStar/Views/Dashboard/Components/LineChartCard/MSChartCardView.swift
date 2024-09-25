//
//  MSLineChartCardView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 21/08/2024.
//

import SwiftUI

private enum Constants {
    static let imageHeight: CGFloat = 25
}

struct MSLineChartCardView<T: HealthEntry>: View {
    let imageName: String
    let title: String
    let dailyActivities: [DailyActivity<T>]
    let arrowDirection: ArrowDirection
    let backgroundColor: Color
    
    @State private var sliderPosition: CGFloat = 0.5
    
    var body: some View {
        let lastDayActivities = dailyActivities.last?.activities ?? []
        
        VStack(spacing: 8) {
            VStack(alignment: .leading, spacing: AppConstants.Padding.extraLarge) {
                HStack {
                    MSRoundImageWithTitle(
                        title: title,
                        imageName: imageName
                    )
                    Spacer()
                    MSUpDownArrow(direction: arrowDirection)
                }
                if let lastActivity = lastDayActivities.last {
                    Text("\(Int(dailyActivities.last?.mainValue ?? 0)) \(lastActivity.unit)")
                        .font(.title)
                        .foregroundStyle(Color.primaryTextColor)
                } else {
                    Text("Aucune activité disponible")
                        .font(.title)
                        .foregroundStyle(Color.primaryTextColor)
                }
            }
            .padding(AppConstants.Padding.medium)
            
            MSLineChartView(
                sliderPosition: $sliderPosition,
                backgroundColor: backgroundColor,
                data: dailyActivities.last?.values ?? [],
                yAxisLabel: lastDayActivities.last?.unit ?? "none"
            )
        }
        .background(backgroundColor.opacity(0.3))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.borderColor, lineWidth: 2)
        )
    }
}

#Preview {
    MSLineChartCardView(
        imageName: "weightIcon",
        title: "Weight",
        dailyActivities: HealthData.fakeStepCountHistory(),
        arrowDirection: .up,
        backgroundColor: Color.weightColor
    )
    .frame(width: 250, height: 400)
}
