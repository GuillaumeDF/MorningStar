//
//  MSStackedChartCardSkeletonView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 24/10/2024.
//

import SwiftUI

struct MSStackedChartCardSkeletonView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack(spacing: AppConstants.Spacing.large) {
                    
                    RoundedRectangle(cornerRadius: AppConstants.Radius.medium)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: geometry.size.width * 0.1, height: geometry.size.height * 0.07)
                    
                    Spacer()
                    
                    ForEach(0..<5, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: AppConstants.Radius.medium)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: geometry.size.width * 0.1, height: geometry.size.height * 0.07)
                    }
                }
                .padding(AppConstants.Padding.medium)
                
                RoundedRectangle(cornerRadius: AppConstants.Radius.medium)
                    .fill(Color.gray.opacity(0.3))
                    .padding(AppConstants.Padding.medium)
            }
            .background(Color.trainingColor.opacity(0.5))
            .cornerRadius(AppConstants.Radius.large)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.Radius.large)
                    .stroke(Color.borderColor, lineWidth: 2)
            )
        }
    }
}

#Preview {
    MSStackedChartCardSkeletonView()
        .frame(height: 400)
}
