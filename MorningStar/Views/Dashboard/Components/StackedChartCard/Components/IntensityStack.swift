//
//  IntensityStack.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 28/08/2024.
//

import SwiftUI

private enum Constants {
    static let dividerHeight: CGFloat = 1
}

struct IntensityStack: View {
    let workout: Workout
    let maxTime: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                ForEach(Array(workout.phaseEntries.enumerated()), id: \.element) { index, workoutPhaseEntry in
                    VStack(spacing: 0) {
                        if index != 0 {
                            Divider()
                                .frame(height: Constants.dividerHeight)
                                .background(Color.borderColor)
                        }
                        
                        Rectangle()
                            .fill(workoutPhaseEntry.value.color)
                            .frame(height: calculateHeight(for: workoutPhaseEntry, with: geometry, isFirstIndex: index == 0))
                    }
                }
            }
        }
    }
    
    private func calculateHeight(for workoutPhaseEntry: HealthData.WorkoutPhaseEntry, with geometry: GeometryProxy, isFirstIndex: Bool) -> CGFloat {
        (geometry.size.height * workoutPhaseEntry.duration) / (maxTime * 60) - (isFirstIndex ? 0 : Constants.dividerHeight)
    }
}

#Preview {
    IntensityStack(workout: WorkoutMockData.hiitWorkout, maxTime: 35)
        .frame(width: 40)
}
