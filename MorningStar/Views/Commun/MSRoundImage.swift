//
//  MSRoundImage.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 12/08/2024.
//

import SwiftUI

private enum Constants {
    static let padding: CGFloat = AppConstants.Padding.small
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
                        Color.borderColor,
                        lineWidth: borderWidth
                    )
            )
            .aspectRatio(contentMode: .fit)
    }
}

#Preview {
    MSRoundImage(imageName: "stepIcon")
}
