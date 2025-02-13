//
//  MSLineChartView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 31/08/2024.
//

import SwiftUI

struct MSLineChartView: View {
    @State private var value: Double = 0
    @State private var date: Date = .now
    @State private var intersectionPoint: CGPoint = .zero
    
    @Binding var sliderPosition: CGFloat
    
    let backgroundColor: Color
    let data: ChartData
    let valueFormatter: (Double) -> String
    let dateFormatter: (Date) -> String

    private var maxValue: Double {
        data.values.map { $0 }.max() ?? 0
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LineChart(
                    data: data.values,
                    maxValue: maxValue,
                    backgroundColor: backgroundColor,
                    size: geometry.size
                )
                
                SliderBar(
                    position: $sliderPosition,
                    backgroundColor: backgroundColor,
                    size: geometry.size
                )
                
                IntersectionPoint(point: intersectionPoint, color: backgroundColor)
                
                ValueDisplay(date: dateFormatter(date), value: valueFormatter(value), position: sliderPosition, size: geometry.size)
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                sliderPosition = max(0, min(1, value.location.x / geometry.size.width))
                                updateIntersection(at: sliderPosition, in: geometry)
                                updateValue(at: sliderPosition)
                                updateDate(at: sliderPosition, from: data.startDate, to: data.endDate)
                            }
                    )
            }
            .onAppear {
                updateIntersection(at: sliderPosition, in: geometry)
                updateValue(at: sliderPosition)
            }
        }
    }

    private func updateIntersection(at position: CGFloat, in geometry: GeometryProxy) {
        let width = geometry.size.width
        let height = geometry.size.height
        let x = position * width

        let scaleFactor = height / CGFloat(maxValue)
        let y = height - CGFloat(value) * scaleFactor

        intersectionPoint = CGPoint(x: x, y: y)
    }
    
    private func updateValue(at position: CGFloat) {
        let floatIndex = position * CGFloat(data.values.count - 1)
        let lowerIndex = Int(floatIndex)
        let upperIndex = min(lowerIndex + 1, data.values.count - 1)
        let fraction = floatIndex - CGFloat(lowerIndex)

        let lowerValue = CGFloat(data.values[lowerIndex])
        let upperValue = CGFloat(data.values[upperIndex])
        let interpolatedValue = lowerValue + (upperValue - lowerValue) * fraction

        value = Double(interpolatedValue)
    }
    
    private func updateDate(at position: CGFloat, from startDate: Date, to endDate: Date) {
        let totalDuration = endDate.timeIntervalSince(startDate)
        let fraction = Double(position)
        let interpolatedTimeInterval = totalDuration * fraction
        date = Date(timeInterval: interpolatedTimeInterval, since: startDate)
    }
}

//#Preview {
//    MSLineChartView(
//        sliderPosition: .constant(0.4),
//        backgroundColor: Color.stepColor,
//        data:
//            [
//                65, 60, 60, 60, 60, 65, 90, 150, 110, 100, 100, 120,
//                180, 130, 100, 110, 120, 200, 350, 250, 120, 90, 80, 70
//            ],
//        yAxisLabel: "Label"
//    )
//}
