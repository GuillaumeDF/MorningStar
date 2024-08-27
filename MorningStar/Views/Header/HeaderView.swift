//
//  HeaderView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 12/08/2024.
//

import SwiftUI

private enum Constants {
    static let imageHeight: CGFloat = 50
}

struct HeaderView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
            HStack {
                MSLogo(size: .medium)
                Spacer()
                VStack(alignment: .leading) {
                    Text("Hello, Guillaume")
                        .font(.largeTitle)
                        .foregroundStyle(Color.primaryTextColor)
                    MSTodayDateTitle()
                }
                Spacer()
                HStack(spacing: AppConstants.Padding.extraLarge) {
                    MSThemeToggleView(initialTheme: colorScheme)
                    MSVerticalSeparator()
                        .padding(.vertical, AppConstants.Padding.extraLarge)
                    MSRoundImage(imageName: "")
                        .frame(height: Constants.imageHeight)
                    
                }
            }
    }
}

#Preview {
    HeaderView()
}
