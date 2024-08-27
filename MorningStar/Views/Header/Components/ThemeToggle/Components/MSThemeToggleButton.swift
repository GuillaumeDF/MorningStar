//
//  MSThemeToggleButton.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 27/08/2024.
//

import SwiftUI

private enum Constants {
    static let blurRadius: CGFloat = 2
    static let offsetLightButton: CGFloat = -60
}

struct MSThemeToggleButton: View {
    var themeMode: ColorScheme
    @Binding var selectedThemeMode: ColorScheme
    
    var body: some View {
        Button(action: {
            selectedThemeMode = themeMode
        }) {
            Label(themeMode.description, systemImage: themeMode.iconName)
                .foregroundColor(Color.primaryTextColor)
                .padding(.horizontal, AppConstants.Padding.extraLarge)
                .padding(.vertical, AppConstants.Padding.medium)
                .background(Color.backgroundColor)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            Color.primaryTextColor,
                            lineWidth: 1
                        )
                )
        }
        .blur(radius: selectedThemeMode == themeMode ? Constants.blurRadius : 0)
        .zIndex(selectedThemeMode == themeMode ? 0 : 1)
        .offset(x: themeMode == .light ? Constants.offsetLightButton : 0)
        .accessibility(label: Text("Switch to \(themeMode.description) mode"))
    }
}

#Preview {
    MSThemeToggleButton(themeMode: .light, selectedThemeMode: .constant(.dark))
}
