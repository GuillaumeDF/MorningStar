//
//  MSVerticalSeparator.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 12/08/2024.
//

import SwiftUI

struct MSVerticalSeparator: View {
    var body: some View {
        Rectangle()
            .fill(Color.primaryTextColor)
            .frame(width: 1)
    }
}

#Preview {
    MSVerticalSeparator()
}
