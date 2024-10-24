//
//  ActivityDataProvider.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 22/10/2024.
//

import Foundation

protocol ActivityDataProvider: ObservableObject {
    associatedtype EntryType
    var periods: [EntryType] { get set }
    var currentPeriod: EntryType { get }
    var allValues: [Double] { get }
    var isEmpty: Bool { get }
}
