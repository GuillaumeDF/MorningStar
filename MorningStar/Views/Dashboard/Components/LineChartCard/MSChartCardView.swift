//
//  MSLineChartCardView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 21/08/2024.
//

import SwiftUI

private enum Constants {
    static let imageHeight: CGFloat = 25
}

struct MSLineChartCardView<T: HealthEntry>: View {
    let imageName: String
    let title: String
    let arrowDirection: ArrowDirection
    let backgroundColor: Color
    
    @StateObject private var viewModel: BaseLineChartViewModel<T>
    @State private var sliderPosition: CGFloat = 0.5
    
     init(imageName: String, title: String, viewModel: BaseLineChartViewModel<T>, backgroundColor: Color, arrowDirection: ArrowDirection) {
         self.imageName = imageName
         self.title = title
         self.backgroundColor = backgroundColor
         self.arrowDirection = arrowDirection
         _viewModel = StateObject(wrappedValue: viewModel)
     }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: AppConstants.Padding.medium) {
                MSDateNavigationView(date: viewModel.formattedSelectedDate, onPreviousDay: viewModel.selectPreviousPeriod, onNextDay: viewModel.selectNextPeriod)
                
                HStack {
                    MSRoundImageWithTitle(
                        title: title,
                        imageName: imageName
                    )
                    Spacer()
                    MSUpDownArrow(direction: arrowDirection)
                }
                
                Text("\(viewModel.formattedSelectedValue) \(viewModel.selectedActivityUnit)")
                    .font(.title)
                    .foregroundStyle(Color.primaryTextColor)
            }
            .padding(AppConstants.Padding.medium)
            
            MSLineChartView(
                sliderPosition: $sliderPosition,
                backgroundColor: backgroundColor,
                data: viewModel.activityValues,
                yAxisLabel: viewModel.selectedActivityUnit
            )
        }
        .background(backgroundColor.opacity(0.3))
        .cornerRadius(AppConstants.Radius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.Radius.large)
                .stroke(Color.borderColor, lineWidth: 2)
        )
    }
}

//#Preview {
//    MSLineChartCardView(
//        imageName: "weightIcon",
//        title: "Weight",
//        dailyActivities: HealthData.fakeStepCountHistory(),
//        arrowDirection: .up,
//        backgroundColor: Color.weightColor
//    )
//    .frame(width: 250, height: 400)
//}
