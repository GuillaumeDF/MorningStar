//
//  LegendView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 28/08/2024.
//

import SwiftUI

struct LegendView: View {
    var color: Color
    var text: String
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: AppConstants.Radius.small)
                .fill(color)
                .frame(width: 20, height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.Radius.small)
                        .stroke(Color.borderColor, lineWidth: 1)
                )
            
            Text(text)
                .foregroundStyle(Color.primaryTextColor)
                .font(.subheadline)
        }
    }
}

#Preview {
    LegendView(color: Color.lowIntensity, text: "low intensity")
}
