//
//  ValueDisplay.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 31/08/2024.
//

import SwiftUI

struct ValueDisplay: View {
    let date: String
    let value: String
    let position: CGFloat
    let size: CGSize
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(date)
                .font(.caption2)
            Text(value)
                .font(.subheadline)
                .bold()
        }
        .position(x: position * size.width, y: (size.height * 0.1) - 20) // TODO: A revoir le - 20
    }
}

#Preview {
    ValueDisplay(date: "16:37", value: "284 count", position: 10, size: CGSize(width: 50, height: 50))
}
