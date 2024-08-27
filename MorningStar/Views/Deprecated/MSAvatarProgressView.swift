//
//  MSAvatarProgressView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 14/08/2024.
//

import SwiftUI

struct MSAvatarProgressView: View {
    var title: String
    var imageName: String
    @Binding var progress: Double

    var body: some View {
        HStack(spacing: AppConstants.Padding.large) {
            MSRoundImage(imageName: imageName)
            MSProgressBarView(title: title, progress: $progress)
        }
    }
}

#Preview {
    MSAvatarProgressView(
        title: "Title",
        imageName: "stepIcon",
        progress: .constant(0.5)
    )
}
