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
    let data: [[IntensitySegment]]
    let stackWidth: CGFloat = Constants.stackWidth
    
    @State private var maxTime: CGFloat = 0
    
    init(data: [[IntensitySegment]]) {
        self.data = data
        _maxTime = State(initialValue: findMaxSumTime(from: data) * 10)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            YAxisLabelsAndGridLines(
                maxTime: Int(maxTime),
                gridLineStartX: Constants.stackSpacingHorizontaly
            )
            .padding(.bottom, Constants.textXHeight)
            
            HStack(spacing: Constants.stackSpacingHorizontaly) {
                ForEach(data, id: \.self) { segments in
                    IntensityStack(segments: segments, maxTime: maxTime)
                        .frame(width: stackWidth)
                }
            }
            .padding(.leading, Constants.stackSpacingHorizontaly)
            .padding(.bottom, Constants.textXHeight)
            
            XAxisLabels(
                dataCount: data.count,
                textWidth: stackWidth,
                labelStartX: Constants.stackSpacingHorizontaly
            )
        }
        .padding([.top, .leading], AppConstants.Padding.medium)
    }
    
    private func findMaxSumTime(from arrays: [[IntensitySegment]]) -> CGFloat {
        arrays.map { $0.reduce(0) { $0 + $1.time } }.max() ?? 0
    }
}

#Preview {
    MSStackedChart(
        data: [
            [
                IntensitySegment(time: 0.2, type: .lowIntensity),
                IntensitySegment(time: 0.3, type: .moderateIntensity),
                IntensitySegment(time: 0.4, type: .lowIntensity),
                IntensitySegment(time: 0.1, type: .highIntensity)
            ],
            [
                IntensitySegment(time: 0.5, type: .moderateIntensity),
                IntensitySegment(time: 0.2, type: .veryHighIntensity),
                IntensitySegment(time: 0.4, type: .highIntensity),
                IntensitySegment(time: 0.7, type: .lowIntensity)
            ],
            [
                IntensitySegment(time: 0.3, type: .lowIntensity),
                IntensitySegment(time: 0.1, type: .moderateIntensity),
                IntensitySegment(time: 0.4, type: .highIntensity),
                IntensitySegment(time: 0.6, type: .veryHighIntensity)
            ],
        ]
    )
    .frame(height: 400)
}
