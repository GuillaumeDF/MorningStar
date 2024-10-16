//
//  IntensityStack.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 28/08/2024.
//

import SwiftUI

struct IntensityStack: View {
    let workoutPhaseEntries: HealthData.WorkoutPhaseEntries
    let maxTime: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                ForEach(Array(workoutPhaseEntries.enumerated()), id: \.element) { index, workoutEntry in
                    VStack(spacing: 0) {
                        // Ajoute un séparateur noir sauf pour la première itération
                        if index != 0 {
                            Divider()
                                .frame(height: 1)
                                .background(Color.borderColor)
                        }
                        
                        Rectangle()
                            .fill(workoutEntry.value.color)
                            .frame(height: calculateHeight(for: workoutEntry, with: geometry))
                    }
                }
            }
        }
    }
    
    private func calculateHeight(for workoutEntry: HealthData.WorkoutEntry, with geometry: GeometryProxy) -> CGFloat {
        (geometry.size.height * workoutEntry.duration) / (maxTime * 60)
    }
}

//#Preview {
//    IntensityStack(segments: [
//        IntensitySegment(time: 0.2, type: .veryHighIntensity),
//        IntensitySegment(time: 0.3, type: .moderateIntensity),
//        IntensitySegment(time: 0.4, type: .lowIntensity),
//        IntensitySegment(time: 0.1, type: .highIntensity)
//    ],
//                   maxTime: 12
//    )
//}
