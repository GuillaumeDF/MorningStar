//
//  MSStackedChart.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/08/2024.
//

import SwiftUI

private enum Constants {
    static let stackSpacingHorizontaly: CGFloat = 25.0
    static let stackWidth: CGFloat = 25.0
    static let textXHeight: CGFloat = 25.0
}

struct MSStackedChart: View {
    var stackWidth: CGFloat
    
    @StateObject private var viewModel: WorkoutStackedChartViewModel
    
    init(viewModel: WorkoutStackedChartViewModel, stackWidth: CGFloat = Constants.stackWidth) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.stackWidth = stackWidth
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            YAxisLabelsAndGridLines(
                maxTime: Int(viewModel.maxTime / 10),
                gridLineStartX: Constants.stackSpacingHorizontaly
            )
            .padding(.bottom, Constants.textXHeight)
            
            TabView(selection: $viewModel.index) {
                ForEach(Array(viewModel.periods.enumerated()), id: \.offset) { index, weeklyWorkoutSessions in
                    HStack(spacing: Constants.stackSpacingHorizontaly) {
                        ForEach(weeklyWorkoutSessions, id: \.self) { dailyWorkoutSessions in
                            ForEach(dailyWorkoutSessions, id: \.self) { workoutPhaseEntries in
                                IntensityStack(workoutPhaseEntries: workoutPhaseEntries, maxTime: viewModel.maxTime)
                                    .frame(width: stackWidth)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, Constants.stackSpacingHorizontaly)
                    .padding(.bottom, Constants.textXHeight)
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .environment(\.layoutDirection, .rightToLeft)

            XAxisLabels(
                labels: viewModel.currentDateLabel,
                textWidth: 40, //stackWidth,
                labelStartX: Constants.stackSpacingHorizontaly
            )
        }
        .padding([.top, .leading], AppConstants.Padding.medium)
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
