//
//  HeaderView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 12/08/2024.
//

import SwiftUI

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
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
            }
        }
        .frame(height: 150)
    }
}

#Preview {
    HeaderView()
}
