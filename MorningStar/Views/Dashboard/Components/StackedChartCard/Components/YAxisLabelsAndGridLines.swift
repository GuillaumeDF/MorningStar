//
//  YAxisLabelsAndGridLines.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 28/08/2024.
//

import SwiftUI

private enum Constants {
    static let labelOffsetX: CGFloat = 10.0
    static let labelIntervalY: Int = 2
}

struct YAxisLabelsAndGridLines: View {
    let maxTime: Int
    let gridLineStartX: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let xPosition = geometry.size.width
            let yInterval = geometry.size.height / CGFloat(maxTime)
            
            ZStack(alignment: .leading) {
                ForEach(0...Int(maxTime), id: \.self) { i in
                    let reversedIndex = Int(maxTime) - i
                    
                    if i % Constants.labelIntervalY == 0 {
                        let yPosition = yInterval * CGFloat(i)
                        
                        yAxisLabel(title: "\(reversedIndex * 10)", yPosition: yPosition)
                        gridLine(xPosition: xPosition, yPosition: yPosition)
                    }
                }
            }
        }
    }

    private func yAxisLabel(title: String, yPosition: CGFloat) -> some View {
        Text(title)
            .font(.caption)
            .foregroundColor(Color.secondaryTextColor)
            .frame(width: gridLineStartX, alignment: .center)
            .position(x: Constants.labelOffsetX, y: yPosition)
    }

    private func gridLine(xPosition: CGFloat, yPosition: CGFloat) -> some View {
        Path { path in
            path.move(to: CGPoint(x: gridLineStartX, y: yPosition))
            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
        }
        .stroke(Color.secondaryTextColor, lineWidth: 1)
    }
}

#Preview {
    YAxisLabelsAndGridLines(maxTime: 4, gridLineStartX: 50)
}
