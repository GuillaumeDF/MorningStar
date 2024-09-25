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

//struct MSLineChartCardViewPreview: View {
//    let dailyActivities: [HealthData.DailyActivity<HealthData.ActivityEntry>]
//    
//    init() {
//        let activity1 = HealthData.ActivityEntry(
//            start: Date().addingTimeInterval(-3600),
//            end: Date(),
//            measurement: Measurement(value: 10000, unit: "steps")
//        )
//        
//        let activity2 = HealthData.ActivityEntry(
//            start: Date().addingTimeInterval(-7200),
//            end: Date().addingTimeInterval(-3600),
//            measurement: Measurement(value: 500, unit: "calories")
//        )
//        
//        let activity3 = HealthData.ActivityEntry(
//            start: Date().addingTimeInterval(-10800),
//            end: Date().addingTimeInterval(-7200),
//            measurement: Measurement(value: 12000, unit: "steps")
//        )
//        
//        self.dailyActivities = [
//            HealthData.DailyActivity(activities: [activity1]),
//            HealthData.DailyActivity(activities: [activity2]),
//            HealthData.DailyActivity(activities: [activity3])
//        ]
//    }
//    
//    var body: some View {
//        MSLineChartCardView(
//            imageName: "weightIcon",
//            title: "Weight",
//            dailyActivity: dailyActivities,
//            arrowDirection: .up,
//            backgroundColor: Color.weightColor
//        )
//    }
//}
//
//#Preview {
//    MSLineChartCardViewPreview()
//        .frame(width: 250, height: 400)
//}
