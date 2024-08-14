//
//  MSAvatarView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 12/08/2024.
//

import SwiftUI

private enum Constants {
    static let avatarHeight: CGFloat = 50
}

struct MSAvatarView: View {
    var imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(
                        Color.primaryTextColor,
                        lineWidth: 1
                    )
            )
            .aspectRatio(contentMode: .fit)
            .frame(maxHeight: Constants.avatarHeight)
    }
}

#Preview {
    MSAvatarView(imageName: "stepIcon")
}
