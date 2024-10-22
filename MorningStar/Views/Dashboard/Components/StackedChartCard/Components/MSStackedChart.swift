//
//  MSStackedChart.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/08/2024.
//

import SwiftUI

class WorkoutStackedChartViewModel: MSChartCardViewModelProtocol {
    typealias EntryType = HealthData.WeeklyWorkoutSessions
    
    @Published var selectedPeriodIndex: Int
    
    var activityPeriods: [EntryType]
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "dd/MM"
        
        return formatter
    }()
    
    init(workoutHistory: [EntryType]) {
        self.activityPeriods = workoutHistory
        self.selectedPeriodIndex = 0
    }
    
    var selectedPeriodActivity: EntryType {
        activityPeriods[selectedPeriodIndex]
    }
    
    var formattedSelectedDate: String { "" }
    
    var formattedSelectedValue: String { "" }
    
    var selectedActivityUnit: String { "" }
    
    var activityValues: [Double] { [] }
    
    var activityDates: [String] {
        activityPeriods[selectedPeriodIndex]
            .flatMap { $0 }
            .map { workoutPhases in
                if let startDate = workoutPhases.first?.startDate {
                    return dateFormatter.string(from: startDate)
                } else {
                    return "???"
                }
            }
    }
    
    func selectPreviousPeriod() { }
    
    func selectNextPeriod() { }
    
    var canSelectPreviousPeriod: Bool {
        selectedPeriodIndex > 0
    }
    
    var canSelectNextPeriod: Bool {
        selectedPeriodIndex < activityPeriods.count - 1
    }
    
    var maxTime: CGFloat {
        return (
            activityPeriods[selectedPeriodIndex]
                .flatMap { $0 }
                .map { workoutPhases in
                    workoutPhases.reduce(0) { total, phase in
                        total + phase.endDate.timeIntervalSince(phase.startDate)
                    }
                }
                .max() ?? 0
        ) / 60
    }
}

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
            
            TabView(selection: $viewModel.selectedPeriodIndex) {
                ForEach(Array(viewModel.activityPeriods.enumerated()), id: \.offset) { index, weeklyWorkoutSessions in
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
                labels: viewModel.activityDates,
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
