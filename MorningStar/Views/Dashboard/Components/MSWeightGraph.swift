//
//  MSWeightGraph.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 21/08/2024.
//

import SwiftUI

struct MSWeightGraph: View {
    let backgroundColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height * 0.2))
                    path.addQuadCurve(to: CGPoint(x: width * 0.25, y: height * 0.3),
                                      control: CGPoint(x: width * 0.125, y: height * 0.1))
                    path.addQuadCurve(to: CGPoint(x: width * 0.5, y: height * 0.2),
                                      control: CGPoint(x: width * 0.375, y: height * 0.4))
                    path.addQuadCurve(to: CGPoint(x: width * 0.75, y: height * 0.4),
                                      control: CGPoint(x: width * 0.625, y: height * 0.1))
                    path.addQuadCurve(to: CGPoint(x: width, y: height * 0.1),
                                      control: CGPoint(x: width * 0.875, y: height * 0.6))
                    path.addLine(to: CGPoint(x: width, y: height))
                    path.addLine(to: CGPoint(x: 0, y: height))
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [backgroundColor.opacity(0.3), Color.clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .stroke(backgroundColor, lineWidth: 2)
            }
        }
    }
}

#Preview {
    MSWeightGraph(backgroundColor: Color.weightColor)
}
