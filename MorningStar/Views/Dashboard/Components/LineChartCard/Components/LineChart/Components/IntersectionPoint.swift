//
//  IntersectionPoint.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 31/08/2024.
//

import SwiftUI

struct IntersectionPoint: View {
    let point: CGPoint
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 10, height: 10)
            .position(point)
    }
}

#Preview {
    IntersectionPoint(point: CGPoint(x: 500, y: 500), color: Color.stepColor)
}
