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
    
    func getExchangeModelFromMemory() -> ExchangeModel {
        var exchangeMod = ExchangeModel()
        if let data = UserDefaults.standard.value(forKey: "exchangeModel") as? Data, let model = try? PropertyListDecoder().decode(ExchangeModel.self, from: data) {
            exchangeMod = model
        }
        return exchangeMod
    }
    
    func getLastSaveTime(_ savedDate: Date) -> String {
        let dateToFormat: Date

        // If there is no saved date, use the current date
        if savedDate == Date.distantPast {
            dateToFormat = Date() // Use the current date
        } else {
            dateToFormat = savedDate // Use the saved date
        }

        let dateFormat = "yyyy MMM dd HH:mm"
        let dateFormatter = DateFormatter()
        // Set the locale to ensure month name is displayed in English
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: dateToFormat)
    }
    
    func createMessage(_ exchangeModel: ExchangeModel, _ userInput: Double, _ savedDate: Date, _ index: Int) -> String {
        guard let buyEUR = exchangeModel.buyEuro,
              let buyUSD = exchangeModel.sellUSD,
              let sellEUR = exchangeModel.sellEuro,
              let sellUSD = exchangeModel.sellUSD
        else {
            return ""
        }
        var message = ""
        if index == 0 {
            message = "Today, \(getLastSaveTime(savedDate)) you can sell \(Int(userInput)) UAH for \( formatDoubleToString(userInput / sellUSD)) USD or \( formatDoubleToString(userInput / sellEUR)) EUR"
        } else {
            message = "Today, \(getLastSaveTime(savedDate)) for \(Int(userInput)) UAH you can buy \( formatDoubleToString(userInput / buyUSD)) USD or \( formatDoubleToString(userInput / buyEUR)) EUR"
        }
        return message
    }
    
}
