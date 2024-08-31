//
//  MSLineChartView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 31/08/2024.
//

import SwiftUI

struct MSLineChartView: View {
    let backgroundColor: Color
    @Binding var sliderPosition: CGFloat
    let data: [Int]
    let yAxisLabel: String
    
    @State private var value: Int = 0
    @State private var intersectionPoint: CGPoint = .zero

    private var maxValue: Int {
        data.max() ?? 0
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LineChart(
                    data: data,
                    backgroundColor: backgroundColor,
                    size: geometry.size
                )
                
                SliderBar(
                    position: $sliderPosition,
                    backgroundColor: backgroundColor,
                    size: geometry.size
                )
                
                IntersectionPoint(point: intersectionPoint, color: backgroundColor)
                
                ValueDisplay(value: value, label: yAxisLabel, position: sliderPosition, size: geometry.size)
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                sliderPosition = max(0, min(1, value.location.x / geometry.size.width))
                                updateValueAndIntersection(at: sliderPosition, in: geometry)
                            }
                    )
            }
            .onAppear {
                updateValueAndIntersection(at: sliderPosition, in: geometry)
            }
        }
    }

    private func updateValueAndIntersection(at position: CGFloat, in geometry: GeometryProxy) {
        let width = geometry.size.width
        let height = geometry.size.height
        let x = position * width

        let scaleFactor = height / CGFloat(maxValue)

        let floatIndex = position * CGFloat(data.count - 1)
        let lowerIndex = Int(floatIndex)
        let upperIndex = min(lowerIndex + 1, data.count - 1)
        let fraction = floatIndex - CGFloat(lowerIndex)

        let lowerValue = CGFloat(data[lowerIndex])
        let upperValue = CGFloat(data[upperIndex])
        let interpolatedValue = lowerValue + (upperValue - lowerValue) * fraction

        let y = height - interpolatedValue * scaleFactor

        intersectionPoint = CGPoint(x: x, y: y)
        value = Int(interpolatedValue)
    }
}

#Preview {
    MSLineChartView(
        backgroundColor: Color.stepColor,
        sliderPosition: .constant(0.4),
        data:
            [
                65, 60, 60, 60, 60, 65, 90, 150, 110, 100, 100, 120,
                180, 130, 100, 110, 120, 200, 350, 250, 120, 90, 80, 70
            ],
        yAxisLabel: "Label"
    )
}
