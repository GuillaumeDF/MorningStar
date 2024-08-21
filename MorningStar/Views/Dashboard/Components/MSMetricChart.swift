//
//  MSMetricChart.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 21/08/2024.
//

import SwiftUI

struct MSMetricChart: View {
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
                    MSAvatarView(imageName: imageName, padding: AppConstants.Padding.small)
                        .frame(width: 25, height: 25)
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.primaryTextColor)
                    Spacer()
                    ArrowView(direction: arrowDirection)
                }
                Text("\(valeur) \(unity)")
                    .font(.title)
                    .foregroundStyle(Color.primaryTextColor)
            }
            .padding(AppConstants.Padding.medium)
            
            MSWeightGraph(backgroundColor: backgroundColor)
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
    MSMetricChart(
        imageName: "weightIcon",
        title: "Weight",
        valeur: "75",
        unity: "kg",
        arrowDirection: .up,
        backgroundColor: Color.weightColor
    )
    .frame(width: 250, height: 400)
}
