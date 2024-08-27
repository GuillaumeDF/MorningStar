//
//  XAxisLabels.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 28/08/2024.
//

import SwiftUI

private enum Constants {
    static let intensityStackSpacing: CGFloat = 30.0
    static let intensityStackWidth: CGFloat = 50.0
    static let paddingBottom: CGFloat = 30.0
}

struct XAxisLabels: View {
    let dataCount: Int

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: Constants.intensityStackSpacing) {
                ForEach(0..<dataCount, id: \.self) { index in
                    let xPosition = Constants.intensityStackSpacing + (Constants.intensityStackWidth / 2)
                    
                    Text("Day \(index + 1)")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .position(x: xPosition, y: geometry.size.height - (Constants.paddingBottom / 2))
                        .frame(width: Constants.intensityStackWidth, height: Constants.paddingBottom)
                }
            }
            .padding(.bottom)
        }
    }
}

#Preview {
    XAxisLabels(dataCount: 10)
}
