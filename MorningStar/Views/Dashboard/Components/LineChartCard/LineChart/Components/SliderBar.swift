//
//  SliderBar.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 31/08/2024.
//

import SwiftUI

struct SliderBar: View {
    @Binding var position: CGFloat
    let backgroundColor: Color
    let size: CGSize

    var body: some View {
        Rectangle()
            .fill(backgroundColor)
            .frame(width: 2)
            .position(x: position * size.width, y: size.height / 2)
    }
}

#Preview {
    SliderBar(
        position: .constant(10),
        backgroundColor: Color.stepColor,
        size: CGSize(width: 50,height: 50)
    )
}
