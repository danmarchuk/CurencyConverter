
//
//  Created by Данік on 22/03/2023.
//

import Foundation
import CoreLocation

protocol ExchangeManagerDelegate {
    func didUpdateExchangeRate(_ manager: ExchangeManager, exchange: ExchangeModel)
    func didFailWithError(error: Error)
}

struct ExchangeManager {
    let exchangeURL = "https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5"
    var delegate: ExchangeManagerDelegate?
    
    func fetchCurrency(){
        let urlString = exchangeURL
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            // create a URL session
            let session = URLSession(configuration: .default)
            // give session a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let exchangeRate = self.parseJSON(safeData) {
                        delegate?.didUpdateExchangeRate(self, exchange: exchangeRate)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ exchangeData: Data) -> ExchangeModel? {
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
            
            return exchangeModel
        } catch {
            print(error)
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}

