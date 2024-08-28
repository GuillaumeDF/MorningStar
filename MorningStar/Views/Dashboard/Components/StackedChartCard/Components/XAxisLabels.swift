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
    let dataCount: Int
    let textWidth: CGFloat
    let labelStartX: CGFloat

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: labelStartX) {
                ForEach(0..<dataCount, id: \.self) { index in
                    let xPosition = labelStartX + (textWidth / 2)
                    
                    Text("Day \(index + 1)")
                        .font(.caption)
                        .foregroundColor(Color.secondaryTextColor)
                        .position(x: xPosition, y: geometry.size.height - (Constants.textHeight / 2))
                        .frame(width: textWidth, height: Constants.textHeight)
                }
            }
        }
    }
}

#Preview {
    XAxisLabels(dataCount: 10, textWidth: 25, labelStartX: 25)
}
