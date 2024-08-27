//
//  MSVerticalSeparator.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 12/08/2024.
//

import SwiftUI

private enum Constants {
    static let borderWidth: CGFloat = 1
}

struct MSVerticalSeparator: View {
    var borderWidth: CGFloat = Constants.borderWidth
    
    var body: some View {
        Rectangle()
            .fill(Color.primaryTextColor)
            .frame(width: borderWidth)
    }
}

#Preview {
    MSVerticalSeparator()
}
