//
//  MorningStarApp.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 06/08/2024.
//

import SwiftUI
import CoreData

@main
struct MorningStarApp: App {
    let coreDataSource = CoreDataSource.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
