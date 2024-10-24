//
//  MSStackedChart.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/08/2024.
//

import SwiftUI

private enum Constants {
    enum Spacing {
        static let horizontalStack: CGFloat = 30.0
        static let trailingPadding: CGFloat = 15.0
    }
    
    enum Size {
        static let defaultStackWidth: CGFloat = 25.0
        static let xAxisLabelHeight: CGFloat = 25.0
        static let xAxisTextWidth: CGFloat = 15.0
    }
    
    enum Layout {
        static let contentPadding: CGFloat = AppConstants.Padding.medium
    }
}

struct MSStackedChart: View {
    var stackWidth: CGFloat
    
    @ObservedObject private var viewModel: WorkoutStackedChartViewModel
    
    init(
        viewModel: WorkoutStackedChartViewModel,
        stackWidth: CGFloat = Constants.Size.defaultStackWidth
    ) {
        _viewModel = ObservedObject(wrappedValue: viewModel)
        self.stackWidth = stackWidth
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            YAxisLabelsAndGridLines(
                maxTime: Int(viewModel.maxTime / 10),
                gridLineStartX: Constants.Spacing.horizontalStack
            )
            .padding(.bottom, Constants.Size.xAxisLabelHeight)
            
            TabView(selection: $viewModel.index) {
                ForEach(Array(viewModel.periods.enumerated()), id: \.offset) { index, weeklyWorkoutSessions in
                    HStack(spacing: Constants.Spacing.horizontalStack) {
                        ForEach(weeklyWorkoutSessions, id: \.self) { dailyWorkoutSessions in
                            ForEach(dailyWorkoutSessions, id: \.self) { workoutPhaseEntries in
                                IntensityStack(
                                    workoutPhaseEntries: workoutPhaseEntries,
                                    maxTime: viewModel.maxTime
                                )
                                .frame(width: stackWidth)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, Constants.Spacing.horizontalStack + Constants.Spacing.trailingPadding)
                    .padding(.bottom, Constants.Size.xAxisLabelHeight)
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .environment(\.layoutDirection, .rightToLeft)

            XAxisLabels(
                labels: viewModel.currentDateLabel,
                textWidth: Constants.Size.xAxisTextWidth + stackWidth + (Constants.Spacing.horizontalStack / 2),
                labelStartX: Constants.Spacing.horizontalStack + Constants.Spacing.trailingPadding,
                defaultStackWidth: Constants.Size.defaultStackWidth
            )
        }
        .padding([.top, .leading], Constants.Layout.contentPadding)
    }
}

#Preview {
    MSStackedChart(viewModel: WorkoutStackedChartViewModel(workoutHistory: WorkoutMockData.fullHistory))
        .frame(height: 400)
}
