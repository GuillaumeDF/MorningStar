//
//  LineChart.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 31/08/2024.
//

import SwiftUI

struct LineChart: View {
    let data: [ChartData]
    let maxValue: Double
    let backgroundColor: Color
    let size: CGSize

    var body: some View {
        Path { path in
            guard let firstData = data.first, let lastData = data.last else { return }
            
            let totalDuration = lastData.endDate.timeIntervalSince(firstData.startDate)
            
            func xPosition(for date: Date) -> CGFloat {
                let elapsedTime = date.timeIntervalSince(firstData.startDate)
                return size.width * CGFloat(elapsedTime / totalDuration)
            }
            
            let scaleFactor = size.height / maxValue

            path.move(to: CGPoint(x: 0, y: size.height))
            
            for entry in data {
                let startX = xPosition(for: entry.startDate)
                let endX = xPosition(for: entry.endDate)
                
                let steps = data.count
                for step in 0...steps {
                    let position = startX + (endX - startX) * CGFloat(step) / CGFloat(steps)
                    
                    let point = calculateCurvePoint(
                        startX: startX,
                        endX: endX,
                        value: entry.value,
                        at: position,
                        height: size.height,
                        scaleFactor: scaleFactor
                    )
                    
                    path.addLine(to: point)
                }
                path.addLine(to: CGPoint(x: endX, y: size.height))
            }
            path.closeSubpath()
        }
        .fill(
            LinearGradient(
                gradient: Gradient(colors: [backgroundColor.opacity(0.3), Color.clear]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .stroke(backgroundColor, lineWidth: 2)
    }
    
    private func calculateCurvePoint(startX: CGFloat, endX: CGFloat, value: Double, at position: CGFloat, height: CGFloat, scaleFactor: CGFloat) -> CGPoint {
        let segmentWidth = endX - startX
        let relativePosition = (position - startX) / segmentWidth
        
        let boundedPosition = max(0, min(1, relativePosition))
        let curveFactor = 4 * boundedPosition * (1 - boundedPosition)
        
        let y = height - CGFloat(value * curveFactor) * scaleFactor
        let x = startX + boundedPosition * segmentWidth
        
        return CGPoint(x: x, y: y)
    }
}

//#Preview {
//    LineChart(
//        data:  [
//            65, 60, 60, 60, 60, 65, 90, 150, 110, 100, 100, 120,
//            180, 130, 100, 110, 120, 200, 350, 250, 120, 90, 80, 70
//        ],
//        maxValue: 350,
//        backgroundColor: Color.stepColor,
//        size: CGSize(width: 500, height: 500)
//    )
//}
