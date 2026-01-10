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
    var viewModel: LineChartViewModel<T>
    @State private var sliderPosition: CGFloat = 0.5

    init(imageName: String, title: String, viewModel: LineChartViewModel<T>, backgroundColor: Color, arrowDirection: ArrowDirection) {
        self.imageName = imageName
        self.title = title
        self.backgroundColor = backgroundColor
        self.arrowDirection = arrowDirection
        self.viewModel = viewModel
    }
    
    var body: some View {
        Group {
            if viewModel.isEmpty {
                MSLineChartCardSkeletonView(backgroundColor: backgroundColor)
            } else {
                VStack {
                    VStack(alignment: .leading, spacing: AppConstants.Padding.medium) {
                        MSDateNavigationView(date: viewModel.currentDateLabel, onPreviousDay: viewModel.selectPreviousPeriod, onNextDay: viewModel.selectNextPeriod)
                        
                        HStack {
                            MSImageWithTitle(
                                title: title,
                                imageName: imageName
                            )
                            Spacer()
                            MSUpDownArrow(direction: viewModel.activityTrend)
                        }
                        
                        Text("\(viewModel.currentValueLabel) \(viewModel.unitLabel)")
                            .font(.title)
                            .foregroundStyle(Color.primaryTextColor)
                    }
                    .padding(AppConstants.Padding.medium)
                    
                    MSLineChartView(
                        sliderPosition: $sliderPosition,
                        backgroundColor: backgroundColor,
                        data: viewModel.data,
                        valueFormatter: viewModel.valueFormatter,
                        dateFormatter: viewModel.dateFormatter
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
    }
}

#Preview {
    MSLineChartCardView(
        imageName: "stepIcon", title: "Step",
        viewModel:
            LineChartViewModel(activityPeriods: HealthData.fakeStepCountHistory()),
        backgroundColor: Color.stepColor,
        arrowDirection: .up
    )
    .frame(width: 250, height: 400)
}
