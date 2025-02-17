//
//  MSTodayDateTitle.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 09/08/2024.
//

import SwiftUI

struct MSTodayDateTitle: View {
    var body: some View {
        Text(todayDate())
            .font(.title)
            .foregroundStyle(Color.secondaryTextColor)
    }

    func todayDate() -> String {
        let formatter = DateFormatter()
        
        formatter.timeZone = .current
        formatter.dateStyle = .long
        
        return formatter.string(from: Date())
    }
}

#Preview {
    MSTodayDateTitle()
}
