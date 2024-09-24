//
//  LineChart.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 31/08/2024.
//

import SwiftUI

struct LineChart: View {
    let data: [Double]
    let maxValue: Double
    let backgroundColor: Color
    let size: CGSize
    
    var body: some View {
        Path { path in
            let scaleFactor = size.height / maxValue
            path.move(to: CGPoint(x: 0, y: size.height - CGFloat(data[0]) * scaleFactor))
            
            for (index, value) in data.enumerated() {
                let x = size.width * CGFloat(index) / CGFloat(data.count - 1)
                let y = size.height - CGFloat(value) * scaleFactor
                
                if index > 0 {
                    let prevX = size.width * CGFloat(index - 1) / CGFloat(data.count - 1)
                    let prevY = size.height - CGFloat(data[index - 1]) * scaleFactor
                    let controlX = (x + prevX) / 2
                    
                    path.addCurve(to: CGPoint(x: x, y: y),
                                  control1: CGPoint(x: controlX, y: prevY),
                                  control2: CGPoint(x: controlX, y: y))
                }
            }
            
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height))
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
}

//#Preview {
//    LineChart(
//        data:  [
//            65, 60, 60, 60, 60, 65, 90, 150, 110, 100, 100, 120,
//            180, 130, 100, 110, 120, 200, 350, 250, 120, 90, 80, 70
//        ],
//        backgroundColor: Color.stepColor,
//        size: CGSize(width: 500, height: 500)
//    )
//}
