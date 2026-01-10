//
//  MSLineChartView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 31/08/2024.
//

import SwiftUI

struct MSLineChartView: View {
    @State private var intersectionValue: Double = 0
    @State private var intersectionDate: Date = .now
    @State private var intersectionPoint: CGPoint = .zero
    
    @Binding var sliderPosition: CGFloat
    
    let backgroundColor: Color
    let data: [ChartData]
    let valueFormatter: (Double) -> String
    let dateFormatter: (Date) -> String

    private var maxValue: Double {
        data.map { $0.value }.max() ?? 0
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LineChart(
                    data: data,
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
                
                ValueDisplay(date: dateFormatter(intersectionDate), value: valueFormatter(intersectionValue), position: sliderPosition, size: geometry.size)
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                sliderPosition = max(0, min(1, value.location.x / geometry.size.width))
                                interpolateSteps(at: sliderPosition, from: data)
                                updateIntersection(at: sliderPosition, in: geometry)
                            }
                    )
            }
            .onAppear {
                interpolateSteps(at: sliderPosition, from: data)
                updateIntersection(at: sliderPosition, in: geometry)
            }
        }
    }

    private func updateIntersection(at position: CGFloat, in geometry: GeometryProxy) {
      let width = geometry.size.width
      let height = geometry.size.height
      let x = position * width // ICI

      let scaleFactor = height / CGFloat(maxValue)
        let y = height - CGFloat(intersectionValue) * scaleFactor

      intersectionPoint = CGPoint(x: x, y: y)
  }

    func interpolateSteps(at position: CGFloat, from chartData: [ChartData]) {
        guard let firstData = chartData.first, let lastData = chartData.last else {
            intersectionValue = -1
            intersectionDate = Date()
            return
        }

        let totalDuration = lastData.endDate.timeIntervalSince(firstData.startDate)
        let targetTime = firstData.startDate.addingTimeInterval(totalDuration * Double(position))

        intersectionDate = targetTime
        for i in 1..<chartData.count {
            let currentData = chartData[i]

            if targetTime >= currentData.startDate && targetTime <= currentData.endDate {
                let segmentDuration = currentData.endDate.timeIntervalSince(currentData.startDate)
                let targetTimeInSegment = targetTime.timeIntervalSince(currentData.startDate)
                let interpolationFactor = targetTimeInSegment / segmentDuration
                let curveFactor = 4 * interpolationFactor * (1 - interpolationFactor)
                let interpolatedValue = currentData.value * curveFactor

                intersectionValue = interpolatedValue
                return
            }
        }
        
        intersectionValue = 0
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
