//
//  MSImage.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 12/08/2024.
//

import SwiftUI

private enum Constants {
    static let padding: CGFloat = AppConstants.Padding.extraSmall
    static let borderWidth: CGFloat = 1
}

struct MSImage: View {
    var imageName: String
    var padding: CGFloat = Constants.padding
    var borderWidth: CGFloat = Constants.borderWidth
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .padding(padding)
            .aspectRatio(contentMode: .fit)
            .foregroundColor(Color.primaryTextColor)
    }
}

#Preview {
    MSImage(imageName: "stepIcon")
}
