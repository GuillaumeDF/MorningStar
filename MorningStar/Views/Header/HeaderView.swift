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
            MSTodayDateTitle()
            Spacer()
            MSThemeToggleView(initialTheme: colorScheme)
        }
    }
}

#Preview {
    HeaderView()
}
