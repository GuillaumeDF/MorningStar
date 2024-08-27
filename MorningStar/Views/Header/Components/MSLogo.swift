//
//  MSLogo.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 09/08/2024.
//

import SwiftUI

private enum Constants {
    static let logoName: String = "morningStarLogo"
    
    static let small: CGFloat = 50
    static let medium: CGFloat = 100
    static let large: CGFloat = 150
}

enum LogoSize {
    case small
    case medium
    case large
    
    var dimensions: CGSize {
        switch self {
        case .small:
            return CGSize(width: Constants.small, height: Constants.small)
        case .medium:
            return CGSize(width: Constants.medium, height: Constants.medium)
        case .large:
            return CGSize(width: Constants.large, height: Constants.large)
        }
    }
}

struct MSLogo: View {
    var size: LogoSize
    
    var body: some View {
        Image(Constants.logoName)
            .resizable()
            .scaledToFit()
            .frame(height: size.dimensions.height)
            .padding()
    }
}

#Preview {
    MSLogo(size: .medium)
}
