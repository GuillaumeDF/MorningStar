//
//  HeaderView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 12/08/2024.
//

import SwiftUI

private enum Constants {
    static let headerHeight: CGFloat = 150
    static let separatorHeight: CGFloat = 50
}

struct HeaderView: View {
    var body: some View {
        HStack {
            MSLogoView(size: .medium)
            Spacer()
            VStack(alignment: .leading) {
                Text("Hello, Guillaume")
                    .font(.largeTitle)
                    .foregroundStyle(.primaryText)
                MSTodayDateTitle()
            }
            Spacer()
            HStack(
                spacing: AppPadding.extraLarge
            ) {
                MSThemeToggleView(initialTheme: .light)
                MSVerticalSeparator()
                    .frame(height: Constants.separatorHeight)
                MSAvatarView(imageName: "")
            }
        }
        .frame(height: Constants.headerHeight)
    }
}

#Preview {
    HeaderView()
}
