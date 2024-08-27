//
//  MSCaloriesChart.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 19/08/2024.
//

import SwiftUI

struct Calories: Identifiable {
    let id = UUID()
    let startTime: String
    let duration: Double
}

struct CaloriesBarView: View {
    var calory: Calories
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.blue)
                .frame(width: 20, height: calory.duration)
            Text(calory.startTime)
                .font(.caption)
                .frame(width: 40, height: 20)
                .padding(.top, 5)
        }
    }
}


struct MSCaloriesChart: View {
    let calories: [Calories] = [
        Calories(startTime: "08:00", duration: 50),
        Calories(startTime: "09:00", duration: 30),
        Calories(startTime: "10:00", duration: 40),
        // Ajoutez d'autres activités
    ]
    
    var body: some View {
        VStack {
            HStack() {
                MSRoundImage(imageName: "caloriesIcon")
                Spacer()
            }
            
            MSDashboardHeaderMetricView(
                title: "Calories Burned",
                value: "882 Kkal"
            )
            .frame(alignment: .center)
            
            ScrollView(.horizontal) {
                HStack(alignment: .bottom, spacing: 10) {
                    ForEach(calories) { calory in
                        CaloriesBarView(calory: calory)
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
    MSCaloriesChart()
}
