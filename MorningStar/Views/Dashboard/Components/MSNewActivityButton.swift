//
//  MSNewActivityButton.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 13/08/2024.
//

import SwiftUI

struct MSNewActivityButton: View {
    var body: some View {
        Button(action: {
            // Action pour le bouton
        }) {
            Text("+ New activity")
                .font(.title2)
                .foregroundColor(Color.primaryTextColor)
                .padding(AppPadding.medium)
                .background(Color.primaryColor)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    MSNewActivityButton()
}
