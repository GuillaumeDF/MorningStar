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
    
    var body: some View {
        VStack(spacing: 8) {
            VStack(alignment: .leading, spacing: AppConstants.Padding.extraLarge) {
                HStack {
                    MSRoundImage(imageName: imageName)
                        .frame(height: Constants.imageHeight)
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.primaryTextColor)
                    Spacer()
                    MSUpDownArrow(direction: arrowDirection)
                }
                Text("\(valeur) \(unity)")
                    .font(.title)
                    .foregroundStyle(Color.primaryTextColor)
            }
            .padding(AppConstants.Padding.medium)
            
            MSLineChart(backgroundColor: backgroundColor)
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
