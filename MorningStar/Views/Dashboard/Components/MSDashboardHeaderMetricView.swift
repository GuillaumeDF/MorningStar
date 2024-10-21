//
//  MSDashboardHeaderMetricView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 13/08/2024.
//

import SwiftUI

struct MSDashboardHeaderMetricView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color.secondaryTextColor)
            Text(value)
                .font(.title)
                .foregroundStyle(Color.primaryTextColor)
        }
    }
}

#Preview {
    MSDashboardHeaderMetricView(title: "Title", value: "value")
}
