//
//  ValueDisplay.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 31/08/2024.
//

import SwiftUI

struct ValueDisplay: View {
    let text: String
    //let formatter: (Double, Date) -> String
    let position: CGFloat
    let size: CGSize

    var body: some View {
        Text(text)
            .position(x: position * size.width, y: (size.height * 0.1) - 20) // TODO: A revoir le - 20
            .font(.footnote)
            .bold()
    }
}

//#Preview {
//    ValueDisplay(value: 150, label: "Step", position: 10, size: CGSize(width: 50, height: 50))
//}
