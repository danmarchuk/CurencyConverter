
//
//  Created by Данік on 22/03/2023.
//

import Foundation
import CoreLocation

protocol ExchangeManagerDelegate {
    func didUpdateExchangeRate(_ manager: ExchangeManager, exchange: ExchangeModel)
    func didFailWithError(error: Error)
}

final class ExchangeManager {
    let exchangeURL = "https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5"
    var delegate: ExchangeManagerDelegate?
    
    func fetchCurrency(){
        let urlString = exchangeURL
        let currentDate = Date()
        let defaults = UserDefaults.standard
        
        if let savedDate = defaults.object(forKey: "lastFetchedDate") as? Date {
            let timeDifference = currentDate.timeIntervalSince(savedDate)
            if timeDifference >= 3600 {
                // If the difference is more than an hour, perform the request
                performRequest(with: urlString)
            }
        } else {
            performRequest(with: urlString)
        }
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            // create a URL session
            let session = URLSession(configuration: .default)
            // give session a task
            let task = session.dataTask(with: url) { [weak self] data, response, error in
                if error != nil {
                    self?.delegate?.didFailWithError(error: error!)
                    return
                }
                // check the response status code
                if let httpResponse = response as? HTTPURLResponse {
                    guard httpResponse.statusCode == 200 else {
                        let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: nil)
                        self?.delegate?.didFailWithError(error: error)
                        return
                    }
                }
                if let safeData = data,
                   let exchangeRate = self?.parseJSONToModel(safeData) {
                    // Update the last fetched date
                    let currentDate = Date()
                    let defaults = UserDefaults.standard
                    defaults.set(currentDate, forKey: "lastFetchedDate")
                    self?.delegate?.didUpdateExchangeRate(self!, exchange: exchangeRate)
                }
            }
            task.resume()
        }
    }
    
    func parseJSONToModel(_ exchangeData: Data) -> ExchangeModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([ExchangeData].self, from: exchangeData)
            let euro = decodedData[0]
            let usd = decodedData[1]
    
            let buyEuro = Double(euro.buy)
            let sellEuro = Double(euro.sale)
            let buyUsd = Double(usd.buy)
            let sellUsd = Double(usd.sale)
            
            let exchangeModel = ExchangeModel(buyEuro: buyEuro, sellEuro: sellEuro, buyUSD: buyUsd, sellUSD: sellUsd)
            let defaults = UserDefaults.standard
            defaults.set(try? PropertyListEncoder().encode(exchangeModel), forKey: "exchangeModel")
            
            return exchangeModel
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

extension ExchangeManager: ExchangeManagerDelegate {
    func didUpdateExchangeRate(_ manager: ExchangeManager, exchange: ExchangeModel) {
    }
    
    func didFailWithError(error: Error) {
    }
}
