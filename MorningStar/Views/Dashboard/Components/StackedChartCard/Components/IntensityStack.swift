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
    let workoutPhaseEntries: HealthData.WorkoutPhaseEntries
    let maxTime: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                ForEach(Array(workoutPhaseEntries.enumerated()), id: \.element) { index, workoutEntry in
                    VStack(spacing: 0) {
                        if index != 0 {
                            Divider()
                                .frame(height: Constants.dividerHeight)
                                .background(Color.borderColor)
                        }
                        
                        Rectangle()
                            .fill(workoutEntry.value.color)
                            .frame(height: calculateHeight(for: workoutEntry, with: geometry, isFirstIndex: index == 0))
                    }
                }
            }
        }
    }
    
    private func calculateHeight(for workoutEntry: HealthData.WorkoutEntry, with geometry: GeometryProxy, isFirstIndex: Bool) -> CGFloat {
        (geometry.size.height * workoutEntry.duration) / (maxTime * 60) - (isFirstIndex ? 0 : Constants.dividerHeight)
    }
}

#Preview {
    IntensityStack(workoutPhaseEntries: WorkoutMockData.hiitWorkout, maxTime: 35)
        .frame(width: 40)
}
