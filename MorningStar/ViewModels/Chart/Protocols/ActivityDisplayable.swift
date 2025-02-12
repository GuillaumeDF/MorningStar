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
    
    func valueGraphFormatter(_ value: Double, at date: Date) -> String
}
