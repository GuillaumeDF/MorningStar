//
//  MSRoundImageWithTitle.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 28/08/2024.
//

import SwiftUI

private enum Constants {
    static let imageHeight: CGFloat = 35
}

struct MSRoundImageWithTitle: View {
    var title: String
    var imageName: String

    var body: some View {
        HStack {
            MSRoundImage(imageName: imageName)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .frame(height: Constants.imageHeight)
    }
}

#Preview {
    MSRoundImageWithTitle(title: "title", imageName: "stepIcon")
}
