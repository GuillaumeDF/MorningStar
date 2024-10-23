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
    let labels: DateRepresentation
    let textWidth: CGFloat
    let labelStartX: CGFloat
    let defaultStackWidth: CGFloat
    
    private var dateLabel: [String] {
        switch labels {
        case .single(let singleDate):
            return [singleDate]
        case .multiple(let dates):
            return dates
        }
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(Array(dateLabel.enumerated()), id: \.offset) { _, label in
                    let xPosition = labelStartX + (defaultStackWidth / 2)
                    
                    Text(label)
                        .font(.caption)
                        .foregroundColor(Color.secondaryTextColor)
                        .position(x: xPosition, y: geometry.size.height - (Constants.textHeight / 2))
                        .frame(width: textWidth, height: Constants.textHeight, alignment: .center)
                }
            }
        }
    }
}

#Preview {
    XAxisLabels(
        labels: .multiple(["03/12", "04/12", "05/12"]),
        textWidth: 100,
        labelStartX: 45,
        defaultStackWidth: 50
    )
}
