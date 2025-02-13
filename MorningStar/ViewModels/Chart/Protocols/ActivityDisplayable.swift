//
//  ActivityDisplayable.swift
//  MorningStar
//
//  Created by Guillaume Djaider Fornari on 22/10/2024.
//

import Foundation

enum DateRepresentation {
    case single(String)
    case multiple([String])
}

protocol ActivityDisplayable {
    var currentDateLabel: DateRepresentation { get }
    var currentValueLabel: String { get }
    var unitLabel: String { get }
    
    func valueFormatter(_ value: Double) -> String
    func dateFormatter(_ date: Date) -> String
}
