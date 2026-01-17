//
//  ActivityDataProvider.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 22/10/2024.
//

import Foundation

protocol ActivityDataProvider {
    associatedtype EntryType
    var periods: [EntryType] { get set }
    var currentPeriod: EntryType { get }
    var data: [ChartData] { get }
    var isEmpty: Bool { get }
}
