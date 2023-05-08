//
//  Currency.swift
//  CurencyConverter
//
//  Created by Данік on 04/05/2023.
//

import UIKit

protocol CurrencyViewControllerDelegate {
    func didSelectCurrency(_ currencyViewController: CurrencyViewController, currency: String)
}



class CurrencyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var delegate: CurrencyViewControllerDelegate?
    
    let currencies = ["USD", "EUR"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusableCell", for: indexPath)
        cell.textLabel?.text = currencies[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Popular"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCurrency = currencies[indexPath.row]
        delegate?.didSelectCurrency(self, currency: selectedCurrency)
        navigationController?.popViewController(animated: true)
    }
}

