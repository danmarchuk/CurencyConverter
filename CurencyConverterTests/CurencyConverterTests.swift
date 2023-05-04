//
//  CurencyConverterTests.swift
//  CurencyConverterTests
//
//  Created by Данік on 29/03/2023.
//

import XCTest
@testable import CurencyConverter

final class ExchangeManagerTests: XCTestCase {
    
    // Create an instance of the ExchangeManager struct
    var exchangeManager: ExchangeManager!
    var mockDelegate: MockExchangeManagerDelegate!

    override func setUp() {
        super.setUp()
        exchangeManager = ExchangeManager()
        mockDelegate = MockExchangeManagerDelegate()
        exchangeManager.delegate = mockDelegate
    }

    override func tearDown() {
        exchangeManager = nil
        super.tearDown()
    }

    // Test the fetchCurrency() function
    func testFetchCurrency() {
        // When
        exchangeManager.fetchCurrency()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // check if the exchange is not nill
            XCTAssertNotNil(self.mockDelegate.myExchange)
            // check if the error is nil
            XCTAssertNil(self.mockDelegate.myError)
        }
    }

    // Test the performRequest(with:) function
    func testPerformRequest() {
        let url = "https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5"
        // when
        exchangeManager.performRequest(with: url)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // check if the exchange is not nill
            XCTAssertNotNil(self.mockDelegate.myExchange)
            // check if the error is nil
            XCTAssertNil(self.mockDelegate.myError)
        }
    }

    // Test the parseJSON(_:) function
    func testParseJSON() {
        // Create some test data
        let json = """
            [
                {
                    "ccy": "EUR",
                    "base_ccy": "UAH",
                    "buy": "40.70000",
                    "sale": "41.20000"
                },
                {
                    "ccy": "USD",
                    "base_ccy": "UAH",
                    "buy": "37.20000",
                    "sale": "37.60000"
                }
            ]
            """
        let data = json.data(using: .utf8)!
        
        // Call the parseJSON function and check the result
        let exchangeModel = exchangeManager.parseJSONToModel(data)
        
        XCTAssertNotNil(exchangeModel)
        XCTAssertEqual(exchangeModel?.buyEuro, 40.7)
        XCTAssertEqual(exchangeModel?.sellEuro, 41.2)
        XCTAssertEqual(exchangeModel?.buyUSD, 37.2)
        XCTAssertEqual(exchangeModel?.sellUSD, 37.6)
    }
}

class MockExchangeManagerDelegate: ExchangeManagerDelegate {
    var myExchange: ExchangeModel?
    var myError: Error?
    
    func didUpdateExchangeRate(_ manager: ExchangeManager, exchange: ExchangeModel) {
        myExchange = exchange
    }
    
    func didFailWithError(error: Error) {
        myError = error
    }
}
