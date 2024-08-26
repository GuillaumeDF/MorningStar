//
//  ContentView.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 12/08/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.backgroundColor.edgesIgnoringSafeArea(.all)
            GeometryReader { geometry in
                VStack {
                    HeaderView()
                        .frame(height: geometry.size.height * 0.15)
                    
                    DashboardView()
                        .frame(height: geometry.size.height * 0.75)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(AppConstants.Padding.extraLarge)
            }
        }
    }
}


#Preview {
    ContentView()
}
