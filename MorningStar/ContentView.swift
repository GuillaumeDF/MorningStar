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
    @StateObject private var viewModel = HealthViewModel()
    
    var body: some View {
        ZStack {
            if viewModel.authorizationStatus {
                Color.backgroundColor.edgesIgnoringSafeArea(.all)
                GeometryReader { geometry in
                    VStack {
                        HeaderView()
                            .frame(height: geometry.size.height * Constants.headerHeight)
                        
                        DashboardView()
                            .frame(height: geometry.size.height * Constants.dashboardHeight)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(AppConstants.Padding.extraLarge)
                }
            } else {
                Text("Autorisation HealthKit refusée ou non accordée")
                    .padding()
            }
        }
        .onAppear {
            viewModel.fetchStepCount()
        }
    }
}


#Preview {
    ContentView()
}
