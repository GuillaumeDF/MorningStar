//
//  ContentView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 12/08/2024.
//

import SwiftUI

private enum Constants {
    static let headerHeight: CGFloat = 0.15
    static let dashboardHeight: CGFloat = 0.75
}

struct ContentView: View {
    @State private var viewModel = HealthDashboardFactory.makeViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel
        ZStack {
            Color.backgroundColor.edgesIgnoringSafeArea(.all)
            GeometryReader { geometry in
                VStack {
                    HeaderView()
                        .frame(height: geometry.size.height * Constants.headerHeight)

                    DashboardView(healthMetrics: $viewModel.healthMetrics)
                        .frame(height: geometry.size.height * Constants.dashboardHeight)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(AppConstants.Padding.extraLarge)
            }
        }
        .task {
            await viewModel.initialize()
        }
    }
}


#Preview {
    ContentView()
}
