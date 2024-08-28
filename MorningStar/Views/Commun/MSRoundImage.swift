//
//  MSRoundImage.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 12/08/2024.
//

import SwiftUI

private enum Constants {
    static let padding: CGFloat = AppConstants.Padding.extraSmall
    static let borderWidth: CGFloat = 1
}

struct MSRoundImage: View {
    var imageName: String
    var padding: CGFloat = Constants.padding
    var borderWidth: CGFloat = Constants.borderWidth
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .padding(padding)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(
                        Color.primaryTextColor,
                        lineWidth: borderWidth
                    )
            )
            .aspectRatio(contentMode: .fit)
            .foregroundColor(Color.primaryTextColor)
    }
}

#Preview {
    MSRoundImage(imageName: "stepIcon")
}
