//
//  MSStackedChart.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/08/2024.
//

import SwiftUI

private enum Constants {
    static let stackSpacingHorizontaly: CGFloat = 50.0
    static let stackWidth: CGFloat = 25.0
    static let textXHeight: CGFloat = 25.0
}

struct MSStackedChart: View {
    let weeklyWorkoutSessions: HealthData.WeeklyWorkoutSessions
    let stackWidth: CGFloat = Constants.stackWidth
    
    @State private var maxTime: CGFloat = 0
    
    init(weeklyWorkoutSessions: HealthData.WeeklyWorkoutSessions) {
        self.weeklyWorkoutSessions = weeklyWorkoutSessions
        _maxTime = State(initialValue: maxSumTime)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            YAxisLabelsAndGridLines(
                maxTime: Int(maxTime / 10),
                gridLineStartX: Constants.stackSpacingHorizontaly
            )
            .padding(.bottom, Constants.textXHeight)
            
            HStack(spacing: Constants.stackSpacingHorizontaly) {
                ForEach(weeklyWorkoutSessions, id: \.self) { dailyWorkoutSessions in
                    ForEach(dailyWorkoutSessions, id: \.self) { workoutPhaseEntries in
                        IntensityStack(workoutPhaseEntries: workoutPhaseEntries, maxTime: maxTime)
                            .frame(width: stackWidth)
                    }
                }
            }
            .padding(.leading, Constants.stackSpacingHorizontaly)
            .padding(.bottom, Constants.textXHeight)
            
            XAxisLabels(
                dailyWorkoutSessions: weeklyWorkoutSessions.first ?? [],
                textWidth: stackWidth,
                labelStartX: Constants.stackSpacingHorizontaly
            )
        }
        .padding([.top, .leading], AppConstants.Padding.medium)
    }
    
    var maxSumTime: CGFloat {
        return (weeklyWorkoutSessions
            .flatMap { $0 }
            .map { workoutPhases in
                workoutPhases.reduce(0) { total, phase in
                    total + phase.endDate.timeIntervalSince(phase.startDate)
                }
            }
            .max() ?? 0) / 60
    }
}

//#Preview {
//    MSStackedChart(
//        data: [
//            [
//                IntensitySegment(time: 0.2, type: .lowIntensity),
//                IntensitySegment(time: 0.3, type: .moderateIntensity),
//                IntensitySegment(time: 0.4, type: .lowIntensity),
//                IntensitySegment(time: 0.1, type: .highIntensity)
//            ],
//            [
//                IntensitySegment(time: 0.5, type: .moderateIntensity),
//                IntensitySegment(time: 0.2, type: .veryHighIntensity),
//                IntensitySegment(time: 0.4, type: .highIntensity),
//                IntensitySegment(time: 0.7, type: .lowIntensity)
//            ],
//            [
//                IntensitySegment(time: 0.3, type: .lowIntensity),
//                IntensitySegment(time: 0.1, type: .moderateIntensity),
//                IntensitySegment(time: 0.4, type: .highIntensity),
//                IntensitySegment(time: 0.6, type: .veryHighIntensity)
//            ],
//        ]
//    )
//    .frame(height: 400)
//}
