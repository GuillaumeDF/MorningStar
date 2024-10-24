//
//  MSLineChartCardSkeletonView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 24/10/2024.
//

import SwiftUI

struct MSLineChartCardSkeletonView: View {
    let backgroundColor: Color
    
    init(backgroundColor: Color) {
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack(alignment: .leading, spacing: AppConstants.Padding.medium) {

                    RoundedRectangle(cornerRadius: AppConstants.Radius.medium)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: geometry.size.height * 0.07)
                    
                    HStack {
                        RoundedRectangle(cornerRadius: AppConstants.Radius.medium)
                            .fill(Color.gray.opacity(0.3))
                            .frame(
                                width: geometry.size.width * 0.20,
                                height: geometry.size.width * 0.20
                            )
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: AppConstants.Radius.medium)
                            .fill(Color.gray.opacity(0.3))
                            .frame(
                                width: geometry.size.width * 0.06,
                                height: geometry.size.width * 0.06
                            )
                    }
                    
                    RoundedRectangle(cornerRadius: AppConstants.Radius.medium)
                        .fill(Color.gray.opacity(0.3))
                        .frame(
                            width: geometry.size.width * 0.35,
                            height: geometry.size.height * 0.1
                        )
                }
                .padding(AppConstants.Padding.medium)
                
                RoundedRectangle(cornerRadius: AppConstants.Radius.medium)
                    .fill(Color.gray.opacity(0.3))
            }
            .background(backgroundColor.opacity(0.5))
            .cornerRadius(AppConstants.Radius.large)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.Radius.large)
                    .stroke(Color.borderColor, lineWidth: 2)
            )
        }
    }
}

#Preview {
    MSLineChartCardSkeletonView(
        backgroundColor: Color.stepColor
    )
    .frame(width: 250, height: 400)
}
