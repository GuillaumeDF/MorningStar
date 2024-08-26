//
//  MSRingsChart.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 19/08/2024.
//

import SwiftUI

struct ActivityRing: Identifiable {
    let id = UUID()
    let name: String
    let progress: Double // Valeur entre 0 et 1
    let color: Color
    let lineWidth: CGFloat // Épaisseur de l'anneau
}


struct NestedRingsView: View {
    let activities: [ActivityRing]
    
    var body: some View {
        ZStack {
            ForEach(activities.indices, id: \.self) { index in
                let activity = activities[index]
                Circle()
                    .stroke(lineWidth: activity.lineWidth)
                    .opacity(0.3)
                    .foregroundColor(activity.color)
                    .frame(width: CGFloat(150 - index * 20), height: CGFloat(150 - index * 20)) // Ajustement de la taille
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(activity.progress))
                    .stroke(style: StrokeStyle(lineWidth: activity.lineWidth, lineCap: .round, lineJoin: .round))
                    .foregroundColor(activity.color)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.easeInOut(duration: 1.0), value: activity.progress)
                    .frame(width: CGFloat(150 - index * 20), height: CGFloat(150 - index * 20)) // Ajustement de la taille
            }
        }
        .frame(width: 150, height: 150)
    }
}


struct MSRingsChart: View {
    let activities: [ActivityRing] = [
        ActivityRing(name: "Move", progress: 0.75, color: .red, lineWidth: 20),
        ActivityRing(name: "Exercise", progress: 0.5, color: .green, lineWidth: 15),
        ActivityRing(name: "Stand", progress: 0.9, color: .blue, lineWidth: 10)
    ]
    
    var body: some View {
        VStack {
            HStack {
                Text("Daily Activity")
                    .font(.title2)
                    .bold()
                Spacer()
            }
            .padding(.bottom, 20)
            
            NestedRingsView(activities: activities)
            
            HStack(spacing: 10) {
                ForEach(activities) { activity in
                    VStack {
                        Text(activity.name)
                            .font(.caption)
                        Text("\(Int(activity.progress * 100))%")
                            .font(.headline)
                            .bold()
                            .foregroundColor(activity.color)
                    }
                }
            }
            .padding(.top, 20)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 20)
            .fill(Color.backgroundColor)
            .shadow(radius: 10))
        .padding()
    }
}

#Preview {
    MSRingsChart()
}
