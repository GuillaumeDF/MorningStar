//
//  MSStackedChart.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 15/08/2024.
//

import SwiftUI

private enum Constants {
    static let intensityStackSpacing: CGFloat = 30.0
    static let intensityStackWidth: CGFloat = 50.0
    static let startXIntensityStack: CGFloat = 30.0
    static let paddingBottom: CGFloat = 30.0
    static let paddingLeading: CGFloat = 40.0
    static let gridLineOffset: CGFloat = 10.0
    static let yInterval: Int = 20
}

enum IntensityType: Hashable {
    case lowIntensity
    case moderateIntensity
    case highIntensity
    case veryHighIntensity
    
    var color: Color {
        switch self {
        case .lowIntensity: return Color.lowIntensityColor
        case .moderateIntensity: return Color.moderateIntensityColor
        case .highIntensity: return Color.highIntensityColor
        case .veryHighIntensity: return Color.veryHighIntensityColor
        }
    }
}

struct IntensitySegment: Hashable {
    var time: CGFloat
    var type: IntensityType
}

struct MSStackedChart: View {
    var data: [[IntensitySegment]]
    
    var body: some View {
        let maxTime = findMaxSumTime(from: data) * 10
        
        ZStack(alignment: .bottomLeading) {
            GeometryReader { geometry in
                yAxisLabelsgridLines(maxTime: maxTime, in: geometry)
                
                VStack {
                    Spacer()
                    HStack(alignment: .bottom, spacing: Constants.intensityStackSpacing) {
                        ForEach(data, id: \.self) { segments in
                            
                            createIntensityStack(for: segments, in: geometry, maxTime: maxTime)
                                .frame(width: Constants.intensityStackWidth)
                            
                        }
                    }
                }
                .padding(.leading, Constants.startXIntensityStack)
                .padding(.bottom, Constants.paddingBottom)
                
                xAxisLabels(in: geometry)
            }
        }
    }

    private func createIntensityStack(for segments: [IntensitySegment], in geometry: GeometryProxy, maxTime: CGFloat) -> some View {
        VStack(spacing: -5) {
            ForEach(segments, id: \.self) { segment in
                Rectangle()
                    .fill(segment.type.color)
                    .frame(height: (((segment.time * 10 / maxTime)) * (geometry.size.height - Constants.paddingBottom)))
                    .cornerRadius(AppConstants.Radius.small)
            }
        }
    }
    
    private func yAxisLabelsgridLines(maxTime: CGFloat, in geometry: GeometryProxy) -> some View {
        ForEach(0..<Int(maxTime), id: \.self) { i in
            let yPosition = geometry.size.height - ((geometry.size.height - Constants.paddingBottom) / maxTime) * CGFloat(i)
            
            if i % (Constants.yInterval / 10) == 0 {
                Text("\(i * 10)")
                    .position(x: Constants.gridLineOffset, y: yPosition - Constants.paddingBottom)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Path { path in
                    path.move(to: CGPoint(x: Constants.startXIntensityStack, y: yPosition - Constants.paddingBottom))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: yPosition - Constants.paddingBottom))
                }
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            }
        }
    }
    
    private func xAxisLabels(in geometry: GeometryProxy) -> some View {
        HStack(spacing: Constants.intensityStackSpacing) {
            ForEach(0..<data.count, id: \.self) { index in
                let xPosition = Constants.intensityStackSpacing + (Constants.intensityStackWidth / 2)
                
                Text("03 / 12")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .position(x: xPosition, y: geometry.size.height - (Constants.paddingBottom / 2))
                    .frame(width: Constants.intensityStackWidth, height: Constants.paddingBottom)
                   
            }
        }
        .padding(.bottom)
    }



    private func findMaxSumTime(from arrays: [[IntensitySegment]]) -> CGFloat {
        arrays.map { $0.reduce(0) { $0 + $1.time } }.max() ?? 0
    }
}

#Preview {
    MSStackedChart(
        data: [
            [
                IntensitySegment(time: 0.2, type: .lowIntensity),
                IntensitySegment(time: 0.3, type: .moderateIntensity),
                IntensitySegment(time: 0.4, type: .lowIntensity),
                IntensitySegment(time: 0.1, type: .highIntensity)
            ],
            [
                IntensitySegment(time: 0.5, type: .moderateIntensity),
                IntensitySegment(time: 0.2, type: .veryHighIntensity),
                IntensitySegment(time: 0.4, type: .highIntensity),
                IntensitySegment(time: 0.7, type: .lowIntensity)
            ],
            [
                IntensitySegment(time: 0.3, type: .lowIntensity),
                IntensitySegment(time: 0.1, type: .moderateIntensity),
                IntensitySegment(time: 0.4, type: .highIntensity),
                IntensitySegment(time: 0.6, type: .veryHighIntensity)
            ],
        ]
    )
    .frame(height: 400)
}
