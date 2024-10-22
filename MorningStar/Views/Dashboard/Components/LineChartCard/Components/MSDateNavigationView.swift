//
//  MSDateNavigationView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 25/09/2024.
//

import SwiftUI

struct MSDateNavigationView: View {
    var date: DateRepresentation
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
        switch date {
        case .single(let singleDate):
            return Text(singleDate)
                .foregroundColor(Color.primaryTextColor)
                .font(.headline)
        case .multiple(let dates):
            return Text(dates.joined(separator: ", "))
                .foregroundColor(Color.primaryTextColor)
                .font(.headline)
        }
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
        date:.single("03 Décembre 1995"),
        onPreviousDay: {},
        onNextDay: {}
    )
}
