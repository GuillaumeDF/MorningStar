//
//  XAxisLabels.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 28/08/2024.
//

import SwiftUI

private enum Constants {
    static let textHeight: CGFloat = 30.0
}

struct XAxisLabels: View {
    let dailyWorkoutSessions: HealthData.DailyWorkoutSessions
    let textWidth: CGFloat
    let labelStartX: CGFloat

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: labelStartX) {
                ForEach(dailyWorkoutSessions, id: \.self) { workoutPhaseEntries in
                    let xPosition = labelStartX + (textWidth / 2)
                    
                    Text(formatDateToDayMonth(workoutPhaseEntries.first?.startDate))
                        .font(.caption)
                        .foregroundColor(Color.secondaryTextColor)
                        .position(x: xPosition, y: geometry.size.height - (Constants.textHeight / 2))
                        .frame(width: textWidth, height: Constants.textHeight)
                }
            }
        }
    }
    
    func formatDateToDayMonth(_ date: Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM"
        
        if let validDate = date {
            return dateFormatter.string(from: validDate)
        } else {
            return ""
        }
    }
}

//#Preview {
//    XAxisLabels(dataCount: 10, textWidth: 25, labelStartX: 25)
//}
