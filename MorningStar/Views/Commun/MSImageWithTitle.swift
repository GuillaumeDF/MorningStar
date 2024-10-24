//
//  MSImageWithTitle.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 28/08/2024.
//

import SwiftUI

private enum Constants {
    static let imageHeight: CGFloat = 35
}

struct MSImageWithTitle: View {
    var title: String
    var imageName: String

    var body: some View {
        HStack {
            MSImage(imageName: imageName)
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(height: Constants.imageHeight)
    }
}

#Preview {
    MSImageWithTitle(title: "title", imageName: "stepIcon")
}
