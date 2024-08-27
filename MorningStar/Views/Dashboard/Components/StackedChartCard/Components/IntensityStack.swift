//
//  IntensityStack.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 28/08/2024.
//

import SwiftUI

private enum Constants {
    static let paddingBottom: CGFloat = 30.0
}

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
    let geometry: GeometryProxy

    var body: some View {
        VStack(spacing: -2) {
            Spacer()
            ForEach(segments, id: \.self) { segment in
                Rectangle()
                    .fill(segment.type.color)
                    .frame(height: calculateHeight(for: segment))
                    .cornerRadius(AppConstants.Radius.small)
            }
        }
    }
    
    private func calculateHeight(for segment: IntensitySegment) -> CGFloat {
        (segment.time / maxTime * 10) * (geometry.size.height - Constants.paddingBottom)
    }
}

#Preview {
    GeometryReader { geometry in
        IntensityStack(segments: [
            IntensitySegment(time: 0.2, type: .lowIntensity),
            IntensitySegment(time: 0.3, type: .moderateIntensity),
            IntensitySegment(time: 0.4, type: .lowIntensity),
            IntensitySegment(time: 0.1, type: .highIntensity)
        ],
                       maxTime: 12,
                       geometry: geometry)
    }
}
