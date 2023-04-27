//
//  Manager.swift
//  CurencyConverter
//
//  Created by Данік on 26/04/2023.
//

import Foundation

struct Manager{
    
    func formatDoubleToString(_ value: Double) -> String {
        return String(format: "%0.2f", value)
    }
}
