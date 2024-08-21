//
//  WorkoutIntensityView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/08/2024.
//

import SwiftUI

struct WorkoutIntensityView: View {
    var body: some View {
        MSLabeledContainer(title: "Sport Workout Statistic", content: {
            WorkoutIntensityChart(
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
            .background(Color.secondaryColor)
            .cornerRadius(AppConstants.Radius.large)
        })
    }
}

#Preview {
    WorkoutIntensityView()
}
