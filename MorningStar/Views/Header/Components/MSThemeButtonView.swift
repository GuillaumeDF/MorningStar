//
//  MSThemeButtonView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 11/08/2024.
//

import SwiftUI

private enum Constants {
    static let blurRadius: CGFloat = 2
    static let offsetLightButton: CGFloat = -60
    static let offsetDarkButton: CGFloat = 0
}

extension ColorScheme {
    var description: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        @unknown default:
            return "Light"
        }
    }
    
    var iconName: String {
        switch self {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        @unknown default:
            return "sun.max.fill"
        }
    }
}

private struct MSThemeToggleButton: View {
    var themeMode: ColorScheme
    @Binding var selectedThemeMode: ColorScheme
    
    var body: some View {
        Button(action: {
            selectedThemeMode = themeMode
        }) {
            Label(themeMode.description, systemImage: themeMode.iconName)
                .foregroundColor(Color.primaryTextColor)
                .padding(.horizontal, AppPadding.extraLarge)
                .padding(.vertical, AppPadding.medium)
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

struct MSThemeToggleView: View {
    @State private var selectedThemeMode: ColorScheme
    
    init(initialTheme: ColorScheme) {
        _selectedThemeMode = State(initialValue: initialTheme)
    }
    
    var body: some View {
        ZStack {
            MSThemeToggleButton(themeMode: .light, selectedThemeMode: $selectedThemeMode)
            MSThemeToggleButton(themeMode: .dark, selectedThemeMode: $selectedThemeMode)
        }
        .preferredColorScheme(selectedThemeMode)
    }
}

#Preview {
    MSThemeToggleView(initialTheme: .light)
}
