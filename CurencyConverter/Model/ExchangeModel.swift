//
//  ExchangeModel.swift
//  CurencyConverter
//
//  Created by Данік on 01/04/2023.
//

import Foundation

struct ExchangeModel: Codable, Equatable {
    var buyEuro: Double?
    var sellEuro: Double?
    var buyUSD: Double?
    var sellUSD: Double?
}
