//
//  DashboardView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 06/08/2024.
//

import SwiftUI

struct DashboardView: View {
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    
    var body: some View {
        VStack {
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
                    spacing: 40
                ) {
                    MSThemeToggleView(initialTheme: .light)
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                }
            }
            .frame(height: 150)
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(0..<12) { index in
                    Rectangle()
                        .fill(Color.cardBackgroundColor)
                        .frame(height: 100)
                        .overlay(
                            Text("Item \(index + 1)")
                                .foregroundColor(.primaryTextColor)
                                .font(.headline)
                        )
                        .cornerRadius(10)
                }
            }
        }
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    DashboardView()
}
