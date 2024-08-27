//
//  MSStepsChart.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 19/08/2024.
//

import SwiftUI

struct Steps: Identifiable {
    let id = UUID()
    let startTime: String
    let duration: Double
}

struct StepsBarView: View {
    var step: Steps
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.blue)
                .frame(width: 20, height: step.duration)
            Text(step.startTime)
                .font(.caption)
                .frame(width: 40, height: 20)
                .padding(.top, 5)
        }
    }
}


struct MSStepsChart: View {
    let steps: [Steps] = [
        Steps(startTime: "08:00", duration: 50),
        Steps(startTime: "09:00", duration: 30),
        Steps(startTime: "10:00", duration: 40),
        // Ajoutez d'autres activités
    ]
    
    var body: some View {
        VStack {
            HStack() {
                MSRoundImage(imageName: "stepIcon")
                Spacer()
            }
            
            MSDashboardHeaderMetricView(
                title: "Steps Taken",
                value: "11 222 steps"
            )
            .frame(alignment: .center)
            
            ScrollView(.horizontal) {
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(steps) { step in
                        StepsBarView(step: step)
                    }
                }
                .padding()
            }
        }
        .padding()
        .background(Color.secondaryColor)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

#Preview {
    MSStepsChart()
}
