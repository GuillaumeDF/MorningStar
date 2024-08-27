//
//  MSLabeledContainer.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 14/08/2024.
//

import SwiftUI

private enum Constants {
    static let backgroundBlurRadius: CGFloat = 2
    static let backgroundOpacity: Double = 0.2
}

struct MSLabeledContainer<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .padding(AppConstants.Padding.medium)
            content
        }
        .background(
            Color.black
                .blur(radius: Constants.backgroundBlurRadius)
                .opacity(Constants.backgroundOpacity)
        )
        .cornerRadius(AppConstants.Radius.large)
    }
}

#Preview {
    MSLabeledContainer(title: "Container") {
        VStack {
            Text("Exemple")
            Text("Exemple")
            Text("Exemple")
        }
        .background(Color.primaryColor)
        .padding()
    }
}
