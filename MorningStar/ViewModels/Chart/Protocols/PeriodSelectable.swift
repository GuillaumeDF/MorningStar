//
//  PeriodSelectable.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 22/10/2024.
//

import Foundation

protocol PeriodSelectable: IndexManageable {
    func selectPreviousPeriod()
    func selectNextPeriod()
    var canSelectPreviousPeriod: Bool { get }
    var canSelectNextPeriod: Bool { get }
}
