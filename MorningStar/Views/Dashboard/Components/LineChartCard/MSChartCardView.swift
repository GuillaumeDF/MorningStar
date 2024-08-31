//
//  MSLineChartCardView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 21/08/2024.
//

import SwiftUI

private enum Constants {
    static let imageHeight: CGFloat = 25
}

struct MSLineChartCardView: View {
    let imageName: String
    let title: String
    let valeur: String
    let unity: String
    let arrowDirection: ArrowDirection
    let backgroundColor: Color
    
    @State private var sliderPosition: CGFloat = 0.5
    
    let sampleData = [
        65, 60, 60, 60, 60, 65, 90, 150, 110, 100, 100, 120,
        180, 130, 100, 110, 120, 200, 350, 250, 120, 90, 80, 70
    ]
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(alignment: .leading, spacing: AppConstants.Padding.extraLarge) {
                HStack {
                    MSRoundImageWithTitle(
                        title: title,
                        imageName: imageName
                    )
                    Spacer()
                    MSUpDownArrow(direction: arrowDirection)
                }
                Text("\(valeur) \(unity)")
                    .font(.title)
                    .foregroundStyle(Color.primaryTextColor)
            }
            .padding(AppConstants.Padding.medium)
            
            MSLineChartView(
                backgroundColor: backgroundColor,
                sliderPosition: $sliderPosition,
                data: sampleData,
                yAxisLabel: unity
            )
        }
        .background(backgroundColor.opacity(0.3))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.borderColor, lineWidth: 2)
        )
    }
}

#Preview {
    MSLineChartCardView(
        imageName: "weightIcon",
        title: "Weight",
        valeur: "75",
        unity: "kg",
        arrowDirection: .up,
        backgroundColor: Color.weightColor
    )
    .frame(width: 250, height: 400)
}
