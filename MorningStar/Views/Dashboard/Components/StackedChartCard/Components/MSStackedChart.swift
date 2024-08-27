//
//  MSStackedChart.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/08/2024.
//

import SwiftUI

private enum Constants {
    static let intensityStackSpacing: CGFloat = 30.0
    static let intensityStackWidth: CGFloat = 50.0
    static let startXIntensityStack: CGFloat = 30.0
    static let paddingBottom: CGFloat = 30.0
}

struct MSStackedChart: View {
    var data: [[IntensitySegment]]
    var intensityStackWidth: CGFloat = Constants.intensityStackWidth
    
    @State private var maxTime: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                YAxisLabelsAndGridLines(maxTime: maxTime)
                
                HStack(alignment: .bottom, spacing: Constants.intensityStackSpacing) {
                    ForEach(data, id: \.self) { segments in
                        IntensityStack(segments: segments, maxTime: maxTime, geometry: geometry)
                            .frame(width: intensityStackWidth)
                    }
                }
                .padding(.leading, Constants.startXIntensityStack)
                .padding(.bottom, Constants.paddingBottom)
                
                XAxisLabels(dataCount: data.count)
            }
            .padding([.top, .leading], AppConstants.Padding.medium)
        }
        .onAppear {
            maxTime = findMaxSumTime(from: data) * 10
        }
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
        ],
        intensityStackWidth: 20
    )
    .frame(height: 400)
}
