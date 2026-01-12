//
//  MSSelectionTimePeriodView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 25/09/2024.
//

import SwiftUI

enum TimePeriod: String, CaseIterable {
    case day = "Jour"
    case week = "Semaine"
    case month = "Mois"
}

struct MSSelectionTimePeriodView: View {
    let backgroundColor: Color
    @Binding var selectedOption: TimePeriod
    
    var body: some View {
        HStack {
            ForEach(TimePeriod.allCases, id: \.self) { period in
                periodButton(for: period)
            }
        }
    }
    
    private func periodButton(for period: TimePeriod) -> some View {
        Button(action: { selectedOption = period }) {
            Text(period.rawValue)
                .font(.subheadline)
                .padding(AppConstants.Padding.small)
                .frame(minHeight: AppConstants.Accessibility.minimumTouchTarget)
                .foregroundColor(selectedOption == period ? Color.primaryTextColor : Color.secondaryTextColor)
                .background(selectedOption == period ? backgroundColor : Color.clear)
                .cornerRadius(AppConstants.Radius.small)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.Radius.small)
                        .stroke(Color.borderColor, lineWidth: 1)
                )
        }
        .accessibilityLabel("View \(period.rawValue)")
        .accessibilityHint("Select to view metrics for this time period")
        .accessibilityAddTraits(selectedOption == period ? .isSelected : [])
    }
}

#Preview {
    MSSelectionTimePeriodView(backgroundColor: Color.stepColor, selectedOption: .constant(.day))
}
