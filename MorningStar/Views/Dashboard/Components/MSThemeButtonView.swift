//
//  MSThemeButtonView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 11/08/2024.
//

import SwiftUI

enum ThemeMode {
    case light
    case dark
    
    var description: String {
        switch self {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
    
    var iconName: String {
        switch self {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        }
    }
    
    var colorScheme: ColorScheme {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

private struct MSThemeToggleButton: View {
    var themeMode: ThemeMode
    @Binding var selectedThemeMode: ThemeMode
    
    var body: some View {
        Button(action: {
            selectedThemeMode = themeMode
        }) {
            Label(themeMode.description, systemImage: themeMode.iconName)
                .foregroundColor(Color.primaryText)
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(Color.backgroundColor)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
                .overlay(
                    Capsule()
                        .stroke(Color.black, lineWidth: 1)
                )
        }
        .blur(radius: selectedThemeMode == themeMode ? 2 : 0)
        .zIndex(selectedThemeMode == themeMode ? 0 : 1)
        .offset(x: themeMode == .light ? -60 : 0)
        .accessibility(label: Text("Switch to \(themeMode.description) mode"))
    }
}

struct MSThemeToggleView: View {
    @State private var selectedThemeMode: ThemeMode
    
    init(initialTheme: ThemeMode) {
        _selectedThemeMode = State(initialValue: initialTheme)
    }
    
    var body: some View {
        ZStack {
            MSThemeToggleButton(themeMode: .light, selectedThemeMode: $selectedThemeMode)
            MSThemeToggleButton(themeMode: .dark, selectedThemeMode: $selectedThemeMode)
        }
        .preferredColorScheme(selectedThemeMode.colorScheme)
    }
}

#Preview {
    MSThemeToggleView(initialTheme: .light)
}
