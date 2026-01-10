//
//  MSTodayDateTitle.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 09/08/2024.
//

import SwiftUI

struct MSTodayDateTitle: View {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateStyle = .long
        return formatter
    }()

    var body: some View {
        Text(Self.dateFormatter.string(from: Date()))
            .font(.title)
            .foregroundStyle(Color.secondaryTextColor)
    }
}

#Preview {
    MSTodayDateTitle()
}
