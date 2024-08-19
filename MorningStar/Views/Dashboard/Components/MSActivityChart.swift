//
//  MSActivityChart.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 19/08/2024.
//

import SwiftUI

struct Activity: Identifiable {
    let id = UUID()
    let startTime: String
    let duration: Double
}

struct ActivityBarView: View {
    var activity: Activity
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.blue)
                .frame(width: 20, height: activity.duration)
            Text(activity.startTime)
                .font(.caption)
                .frame(width: 40, height: 20)
                .padding(.top, 5)
        }
    }
}


struct MSActivityChart: View {
    let activities: [Activity] = [
            Activity(startTime: "08:00", duration: 50),
            Activity(startTime: "09:00", duration: 30),
            Activity(startTime: "10:00", duration: 40),
            // Ajoutez d'autres activités
        ]
    
    var body: some View {
        VStack {
            HStack() {
                MSAvatarView(imageName: "stepIcon")
                Spacer()
            }
            
            MSDashboardHeaderMetricView(
                title: "Active Minutes",
                value: "125 Min"
            )
            .frame(alignment: .center)
            
            ScrollView(.horizontal) {
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(activities) { activity in
                        ActivityBarView(activity: activity)
                    }
                }
                .padding()
            }
        }
        .padding()
        .background(Color.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

#Preview {
    MSActivityChart()
}
