//
//  Manager.swift
//  CurencyConverter
//
//  Created by Данік on 26/04/2023.
//

import Foundation

protocol DoubleFormatter {
    func formatDoubleToString(_ value: Double) -> String
}

struct Manager: DoubleFormatter {
    func formatDoubleToString(_ value: Double) -> String {
        return String(format: "%0.2f", value)
    }
}
