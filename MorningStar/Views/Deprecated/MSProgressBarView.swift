//
//  MSProgressBarView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 14/08/2024.
//

import SwiftUI

struct MSProgressBarView: View {
    var title: String
    @Binding var progress: Double

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.subheadline)
                    .foregroundColor(Color.secondaryTextColor)
            }
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle())
        }
    }
}

#Preview {
    MSProgressBarView(
        title: "Title",
        progress: .constant(0.5)
    )
}
