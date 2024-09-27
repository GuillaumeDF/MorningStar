//
//  MSDateNavigationView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 25/09/2024.
//

import SwiftUI

struct MSDateNavigationView: View {
    var date: String
    let onPreviousDay: () -> Void
    let onNextDay: () -> Void
    
    var body: some View {
        HStack {
            navigationButton(direction: .previous)
            Spacer()
            dateLabel
            Spacer()
            navigationButton(direction: .next)
        }
    }
    
    private var dateLabel: some View {
        Text(date)
            .foregroundColor(Color.primaryTextColor)
            .font(.headline)
    }
    
    private func navigationButton(direction: NavigationDirection) -> some View {
        Button(action: {
            direction == .previous ? onPreviousDay() : onNextDay()
        }) {
            Image(systemName: direction.imageName)
                .padding(AppConstants.Padding.small)
                .foregroundColor(Color.primaryTextColor)
                .cornerRadius(AppConstants.Radius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.Radius.medium)
                        .stroke(Color.borderColor, lineWidth: 1)
                )
        }
    }
}

private enum NavigationDirection {
    case previous, next
    
    var imageName: String {
        switch self {
        case .previous:
            return "chevron.left"
        case .next:
            return "chevron.right"
        }
    }
}

#Preview {
    MSDateNavigationView(
        date: "03 Décembre 1995",
        onPreviousDay: {},
        onNextDay: {}
    )
}
