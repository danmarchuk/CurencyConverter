//
//  TableViewCell.swift
//  CurencyConverter
//
//  Created by Данік on 31/03/2023.
//

import UIKit

class TableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBOutlet weak var currencyButtonOutlet: UIButton!
    @IBAction func currencyButton(_ sender: UIButton) {
    }
    
    @IBOutlet weak var currencyTextFieldOutlet: UITextField!
    
    @IBAction func currencyTextField(_ sender: UITextField) {
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}


