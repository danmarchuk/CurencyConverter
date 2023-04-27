//
//  ExchangeData.swift
//  CurencyConverter
//
//  Created by Данік on 01/04/2023.
//

import Foundation

struct ExchangeData: Decodable {
    let ccy: String
    let base_ccy: String
    let buy: String
    let sale: String
}

