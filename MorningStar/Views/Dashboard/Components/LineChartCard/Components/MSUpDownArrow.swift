//
//  MSUpDownArrow.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 21/08/2024.
//

import SwiftUI

enum ArrowDirection {
    case up
    case down
}

struct MSUpDownArrow: View {
    var direction: ArrowDirection
    
    var body: some View {
        Image(systemName: direction == .up ? "arrow.up" : "arrow.down")
            .foregroundColor(Color.primaryTextColor)
    }
}

#Preview {
    MSUpDownArrow(direction: .down)
}
