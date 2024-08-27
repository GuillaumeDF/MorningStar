//
//  MSThemeToggleView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 27/08/2024.
//

import SwiftUI

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
