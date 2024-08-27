//
//  YAxisLabelsAndGridLines.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 28/08/2024.
//

import SwiftUI

private enum Constants {
    static let startXIntensityStack: CGFloat = 30.0
    static let paddingBottom: CGFloat = 30.0
    static let gridLineOffset: CGFloat = 10.0
    static let yInterval: Int = 20
}

struct YAxisLabelsAndGridLines: View {
    let maxTime: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                ForEach(0...Int(maxTime * 10), id: \.self) { i in
                    if i % Constants.yInterval == 0 {
                        gridLineWithLabel(for: i, in: geometry)
                    }
                }
            }
        }
    }

    private func gridLineWithLabel(for i: Int, in geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            gridLine(for: i, in: geometry)
            yAxisLabel(for: i, in: geometry)
        }
    }

    private func yAxisLabel(for i: Int, in geometry: GeometryProxy) -> some View {
        Text("\(i)")
            .font(.caption)
            .foregroundColor(.gray)
            .frame(width: Constants.startXIntensityStack, alignment: .leading)
            .position(x: Constants.gridLineOffset, y: yPosition(for: i, in: geometry))
    }

    private func gridLine(for i: Int, in geometry: GeometryProxy) -> some View {
        Path { path in
            path.move(to: CGPoint(x: Constants.startXIntensityStack, y: yPosition(for: i, in: geometry)))
            path.addLine(to: CGPoint(x: geometry.size.width, y: yPosition(for: i, in: geometry)))
        }
        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
    }

    private func yPosition(for i: Int, in geometry: GeometryProxy) -> CGFloat {
        geometry.size.height - ((geometry.size.height - Constants.paddingBottom) / CGFloat(maxTime * 10)) * CGFloat(i) - Constants.paddingBottom
    }
}

#Preview {
    YAxisLabelsAndGridLines(maxTime: 4)
}
