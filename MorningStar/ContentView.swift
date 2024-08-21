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
            VStack {
                HeaderView()
                DashboardView()
                    
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(AppConstants.Padding.extraLarge)
        }
    }
}

#Preview {
    ContentView()
}
