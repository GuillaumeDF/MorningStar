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
                gridLineStartX: Constants.Spacing.horizontalStack,
                trailingPadding: Constants.Spacing.trailingPadding
            )
            .padding(.bottom, Constants.Size.xAxisLabelHeight)
            
            TabView(selection: $viewModel.index) {
                ForEach(Array(viewModel.periods.enumerated()), id: \.offset) { index, weeklyWorkout in
                    // Nouvelle vue intermédiaire pour isoler le layout direction
                    ZStack {
                        HStack(spacing: Constants.Spacing.horizontalStack) {
                            ForEach(weeklyWorkout.dailyWorkouts, id: \.self) { dailyWorkout in
                                ForEach(dailyWorkout.workouts, id: \.self) { workout in
                                    IntensityStack(
                                        workout: workout,
                                        maxTime: viewModel.maxTime
                                    )
                                    .frame(width: stackWidth)
                                }
                            }
                        }
                    }
                    .environment(\.layoutDirection, .leftToRight)
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
