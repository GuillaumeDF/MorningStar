//
//  MSLogoView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 09/08/2024.
//

import SwiftUI

enum LogoSize {
    case small
    case medium
    case large
    
    var dimensions: CGSize {
        switch self {
        case .small:
            return CGSize(width: 50, height: 50)
        case .medium:
            return CGSize(width: 100, height: 100)
        case .large:
            return CGSize(width: 150, height: 150)
        }
    }
}

struct MSLogoView: View {
    var size: LogoSize
    
    var body: some View {
        Image("morningStarLogo")
            .resizable()
            .scaledToFit()
            .frame(height: size.dimensions.height)
            .padding()
    }
}

#Preview {
    MSLogoView(size: .medium)
}
