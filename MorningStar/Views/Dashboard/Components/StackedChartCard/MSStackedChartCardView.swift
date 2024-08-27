//
//  MSStackedChartCardView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/08/2024.
//

import SwiftUI

struct IntensitySegment: Hashable {
    var time: CGFloat
    var type: IntensityType
}

struct MSStackedChartCardView: View {
    var body: some View {
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
                ]
            ]
        )
        .background(Color.trainingColor.opacity(0.5))
        .cornerRadius(AppConstants.Radius.large)
    }
}

#Preview {
    MSStackedChartCardView()
        .frame(height: 500)
}
