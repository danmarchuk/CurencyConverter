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
    let savedDate = UserDefaults.standard.object(forKey: "savedDate") as? Date ?? Date.distantPast
    var exchangeModel = ExchangeModel()
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
    let manager = Manager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpViewShadow()
        setUpTableView()
        exchangeManager.delegate = self
        exchangeManager.fetchCurrency()
        dateLabel.text = getLastSaveTime()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                view.addGestureRecognizer(tapGesture)
        segmentedControlOutlet.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
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
        let dateFormat = "yyyy MMMM dd HH:mm"
        let dateFormatter = DateFormatter()
        // Set the locale to ensure month name is displayed in English
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: savedDate)
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
        
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(savedDate)
        let oneHour: TimeInterval = 3600
        
        // if an hour elapsed from the last update, refresh the model
        if timeInterval >= oneHour {
            // Update the time here
            UserDefaults.standard.set(currentDate, forKey: "savedDate")
            // save the exchange model to the user defaults
            let defaults = UserDefaults.standard
            defaults.set(try? PropertyListEncoder().encode(exchange), forKey: "exchangeModel")
            getExchangeModelFromMemory()
        } else {
            getExchangeModelFromMemory()
        }
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
        // Update the second textfield with the calculated value
        if let cell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? TableViewCell {
            if segment == 0 {
                cell.currencyTextFieldOutlet.text = manager.formatDoubleToString(userInput / buyEUR)
            } else if segment == 1 {
                cell.currencyTextFieldOutlet.text = manager.formatDoubleToString(userInput / sellEUR)
            }
        }
        
        if let cell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? TableViewCell {
            if segment == 0 {
                cell.currencyTextFieldOutlet.text = manager.formatDoubleToString(userInput / buyUSD)
            } else if segment == 1 {
                cell.currencyTextFieldOutlet.text = manager.formatDoubleToString(userInput / sellUSD)
            }
        }
    }
}
