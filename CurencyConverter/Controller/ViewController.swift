//
//  ViewController.swift
//  CurencyConverter
//
//  Created by Данік on 29/03/2023.
//

import UIKit

final class ViewController: UIViewController {
    
    
    var exchangeManager = ExchangeManager()
    var currencyArr: [String] = ["UAH", "EUR", "USD"]
    var userInput = 0.0
    let fourSpaces = "    "
    // get last save date from the memory
    let savedDate = UserDefaults.standard.object(forKey: "lastFetchedDate") as? Date ?? Date.distantPast
    var exchangeModel = ExchangeModel()
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
    let manager = Manager()
    var currencyViewController = CurrencyViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("thi is tha saved date \(savedDate)")
        print(exchangeModel)
        // Do any additional setup after loading the view.
        setUpViewShadow()
        setUpTableView()
        exchangeManager.delegate = self
        exchangeManager.fetchCurrency()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        segmentedControlOutlet.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        getExchangeModelFromMemory()
        DispatchQueue.main.async {
            self.dateLabel.text = self.getLastSaveTime()
            self.putValueInTheCell(self.segmentedControlOutlet.selectedSegmentIndex)
        }
    }
    
    @IBAction func buySellAction(_ sender: UISegmentedControl) {
        putValueInTheCell(sender.selectedSegmentIndex)
    }
    
    func setUpViewShadow() {
        // Set up the shadow
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOpacity = 0.5
        mainView.layer.shadowOffset = CGSize(width: 0, height: 2)
        mainView.layer.shadowRadius = 4
        mainView.layer.cornerRadius = 10
    }
    
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }
    
    func getExchangeModelFromMemory() {
        if let data = UserDefaults.standard.value(forKey: "exchangeModel") as? Data, let model = try? PropertyListDecoder().decode(ExchangeModel.self, from: data) {
            exchangeModel = model
        }
    }
    
    func getLastSaveTime() -> String {
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

    
    @IBAction func shareButtonAction(_ sender: UIButton) {
        guard let buyEUR = exchangeModel.buyEuro,
              let buyUSD = exchangeModel.sellUSD,
              let sellEUR = exchangeModel.sellEuro,
              let sellUSD = exchangeModel.sellUSD
        else {
            return
        }
        var message = ""
        
        if segmentedControlOutlet.selectedSegmentIndex == 0 {
            message = "Today, \(getLastSaveTime()) you can sell \(Int(userInput)) UAH for \( manager.formatDoubleToString(userInput / sellUSD)) USD or \( manager.formatDoubleToString(userInput / sellEUR)) EUR"
        } else {
            message = "Today, \(getLastSaveTime()) for \(Int(userInput)) UAH you can buy \( manager.formatDoubleToString(userInput / buyUSD)) USD or \( manager.formatDoubleToString(userInput / buyEUR)) EUR"
        }
        
        let activityController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        present(activityController, animated: true)
    }
    
    @IBAction func addCurrencyButton(_ sender: UIButton) {
        performSegue(withIdentifier: "fromMainToCurrency", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromMainToCurrency" {
            let destinationVC = segue.destination as! CurrencyViewController
            destinationVC.delegate = self
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currencyArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        cell.currencyButtonOutlet.setTitle(currencyArr[indexPath.row] + fourSpaces, for: .normal)
        cell.currencyTextFieldOutlet.layer.cornerRadius = 5.0
        //        cell.currencyTextFieldOutlet.layer.borderWidth = 0.5
        //        cell.currencyTextFieldOutlet.layer.borderColor = UIColor.lightGray.cgColor
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 30))
        cell.currencyTextFieldOutlet.leftView = paddingView
        cell.currencyTextFieldOutlet.leftViewMode = .always
        cell.currencyTextFieldOutlet.delegate = self
        cell.currencyTextFieldOutlet.accessibilityIdentifier = "TextField_\(currencyArr[indexPath.row])"
        cell.currencyTextFieldOutlet.backgroundColor = UIColor(named: "inactiveGray")
        if indexPath.row == 0 {
            cell.currencyTextFieldOutlet.isEnabled = true
            cell.currencyTextFieldOutlet.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)), for: .editingChanged)
            cell.currencyTextFieldOutlet.accessibilityIdentifier = "TextField_0"
        } else {
            cell.currencyTextFieldOutlet.isEnabled = false
            cell.currencyTextFieldOutlet.backgroundColor = UIColor(named: "inactiveGray")
            cell.currencyTextFieldOutlet.textColor = .darkGray
        }
        return cell
    }
}

// MARK: - ExchangeManagerDelegate
extension ViewController: ExchangeManagerDelegate {
    func didUpdateExchangeRate(_ manager: ExchangeManager, exchange: ExchangeModel) {
        exchangeModel = exchange
    }
    
    func didFailWithError(error: Error) {
        getExchangeModelFromMemory()
    }
}

// MARK: - UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.blue.cgColor
        if textField.tag == 0 {
            textField.keyboardType = .numberPad
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0.0
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Get the value of the first textfield
        guard let firstValue = Double(textField.text ?? "") else {
            return
        }
        userInput = firstValue
        putValueInTheCell(segmentedControlOutlet.selectedSegmentIndex)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func putValueInTheCell(_ segment: Int) {
        guard let buyEUR = exchangeModel.buyEuro,
              let buyUSD = exchangeModel.sellUSD,
              let sellEUR = exchangeModel.sellEuro,
              let sellUSD = exchangeModel.sellUSD
        else {
            return
        }
        
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        
        for row in 0..<numberOfRows {
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? TableViewCell {
                let currency = cell.currencyButtonOutlet.title(for: .normal)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                
                var conversionRate: Double? = nil
                
                if segment == 0 {
                    switch currency {
                    case "EUR":
                        conversionRate = buyEUR
                    case "USD":
                        conversionRate = buyUSD
                    default:
                        break
                    }
                } else if segment == 1 {
                    switch currency {
                    case "EUR":
                        conversionRate = sellEUR
                    case "USD":
                        conversionRate = sellUSD
                    default:
                        break
                    }
                }
                
                if let rate = conversionRate {
                    cell.currencyTextFieldOutlet.text = manager.formatDoubleToString(userInput / rate)
                }
            }
        }
    }
    
}

extension ViewController: CurrencyViewControllerDelegate {
    func didSelectCurrency(_ currencyViewController: CurrencyViewController, currency: String) {
        currencyArr.append(currency)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
