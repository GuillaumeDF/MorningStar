//
//  IntensityStack.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 28/08/2024.
//

import SwiftUI

enum IntensityType: Hashable {
    case lowIntensity, moderateIntensity, highIntensity, veryHighIntensity

    var color: Color {
        switch self {
        case .lowIntensity: return .blue
        case .moderateIntensity: return .green
        case .highIntensity: return .orange
        case .veryHighIntensity: return .red
        }
    }
}

struct IntensityStack: View {
    let segments: [IntensitySegment]
    let maxTime: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                ForEach(segments, id: \.self) { segment in
                    Rectangle()
                        .fill(segment.type.color)
                        .frame(height: calculateHeight(for: segment, with: geometry))
                        .cornerRadius(AppConstants.Radius.small)
                }
            }
        }
    }
    
    private func calculateHeight(for segment: IntensitySegment, with geometry: GeometryProxy) -> CGFloat {
        ((geometry.size.height * segment.time) / maxTime) * 10
    }
}

#Preview {
    IntensityStack(segments: [
        IntensitySegment(time: 0.2, type: .lowIntensity),
        IntensitySegment(time: 0.3, type: .moderateIntensity),
        IntensitySegment(time: 0.4, type: .lowIntensity),
        IntensitySegment(time: 0.1, type: .highIntensity)
    ],
                   maxTime: 12
    )
    
}
