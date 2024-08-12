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
}

#Preview {
    DashboardView()
}
