//
//  CurencyConverterUITests.swift
//  CurencyConverterUITests
//
//  Created by Данік on 29/03/2023.
//

import XCTest
@testable import CurencyConverter

final class CurencyConverterUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func testTableViewHasCells() {
        let cells = app.tables.cells
        XCTAssert(cells.count == 3, "Expected 3 cells, but found \(cells.count)")
    }

    func testTableCellTextField() {
        let cell = app.tables.cells.element(boundBy: 0)
        let textField = cell.textFields["TextField_0"]
        XCTAssert(textField.exists, "Currency text field doesn't exist")
        textField.tap()
        textField.typeText("100")
        XCTAssertEqual(textField.value as? String, "100", "TextField value is not equal to expected value")
    }

    func testShareButton() {
        let shareButton = app.buttons["shareButton"]
        XCTAssert(shareButton.exists, "Share button doesn't exist")
        shareButton.tap()
    }
}
