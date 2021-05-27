//
//  CreditCardVC.swift
//  Rescounts
//
//  Created by Admin on 17/05/2021.
//  Copyright © 2021 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import Stripe

class CreditCardVC: UIViewController {

    var cvvValue = ""
    var onRowSelected: ((String)->())?
    var onVCDismiss: (()->())?
    var cellsArray = [TableModel]()
    var tableView: UITableView!
    var picker: UIPickerView!
    var yearsArr = [Int]()
    let monthsArr = [1,2,3,4,5,6,7,8,9,10,11,12]
    var countriesArr = ["Canada","USA","Egypt"]
    var provinceArr = ["test1", "test2"]
    var dataArr = [Any]()
    override func viewDidLoad() {
        super.viewDidLoad()
        createTableCells()
        createTableView()
        for num in 2021...2040{
            yearsArr.append(num)
        }
        createPicker()
    }
    
    private func createTableView(){
        tableView = UITableView.init()
        tableView.register(TextFieldLabelTableCell.self, forCellReuseIdentifier: "\(TextFieldLabelTableCell.self)")
        tableView.register(DateViewTabelCell.self, forCellReuseIdentifier: "\(DateViewTabelCell.self)")
        tableView.register(DropDownTableCell.self, forCellReuseIdentifier: "\(DropDownTableCell.self)")
        tableView.register(ButtonTableCell.self, forCellReuseIdentifier: "\(ButtonTableCell.self)")
        tableView.separatorColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        self.view.addSubview(tableView)
        self.view.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -15),tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 15)])
    }
    private func createPicker() {
        picker = UIPickerView.init()
        picker.isHidden = true
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
        self.view.addSubview(picker)
        self.view.bringSubview(toFront: picker)
        picker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([picker.leadingAnchor.constraint(equalTo: self.view.leadingAnchor), picker.trailingAnchor.constraint(equalTo: self.view.trailingAnchor), picker.heightAnchor.constraint(equalToConstant: 300),picker.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)])
    }
    func showPicker(onRowSelected: ((String)->())?){
        picker.reloadAllComponents()
        picker.isHidden = false
        tableView.alpha = 0.5
        self.onRowSelected = onRowSelected
    }
 
    func hidePicker(){
        picker.isHidden = true
        tableView.alpha = 1
    }
    private func createTableCells(){
        addNewCell(cellID: "\(TextFieldLabelTableCell.self)", key: Keys.creditCard.rawValue, title: SectionTitle.creditCard.rawValue,msgError: "Please enter a valide card number",isRequired: true)
        
        addNewCell(cellID: "\(DateViewTabelCell.self)", key: Keys.exprirationDate.rawValue, title: SectionTitle.exprirationDate.rawValue,msgError: "invalide Expriration Date and CVV", isRequired: true)
        
        addNewCell(cellID: "\(TextFieldLabelTableCell.self)", key: Keys.cardHolder.rawValue, title: SectionTitle.cardHolder.rawValue, msgError: "Please enter a card Holder's name", isRequired: true)
        
        addNewCell(cellID: "\(TextFieldLabelTableCell.self)", key: Keys.address1.rawValue, title: SectionTitle.address1.rawValue, msgError: "Please enter a address 1 field", isRequired: true)
        
        addNewCell(cellID: "\(TextFieldLabelTableCell.self)", key: Keys.address2.rawValue, title: SectionTitle.address2.rawValue, msgError: "Please enter a address 2 field", isRequired: true)
        
        addNewCell(cellID: "\(TextFieldLabelTableCell.self)", key: Keys.addressCity.rawValue, title: SectionTitle.addressCity.rawValue, msgError: "Please enter a city", isRequired: true)
        
        addNewCell(cellID: "\(TextFieldLabelTableCell.self)", key: Keys.postalCode.rawValue, title: SectionTitle.postalCode.rawValue, msgError: "Please enter a postal code", isRequired: true)
        
        addNewCell(cellID: "\(DropDownTableCell.self)", key: Keys.province.rawValue, title: SectionTitle.province.rawValue, msgError: "Please enter a province", isRequired: true)
        
        addNewCell(cellID: "\(DropDownTableCell.self)", key: Keys.country.rawValue, title: SectionTitle.country.rawValue, msgError: "Please enter a country", isRequired: true)
        
        addNewCell(cellID: "\(ButtonTableCell.self)", key: "", title: "")
    }

    private func addNewCell(cellID: String, key: String, title: String,msgError: String? = nil, isRequired: Bool = false){
        var tableModel = TableModel.init(cellID: cellID, key: key, value: nil, title: title, msgError: msgError, isRequired: isRequired)
        tableModel.index = cellsArray.count
        cellsArray.append(tableModel)
    }
    
    func addAdressRequest(){
        let requiredFildes = cellsArray.filter{$0.isRequired == true}
        var errorCount = 0
        requiredFildes.forEach{ (cellModel) in
            let value = cellModel.value
            if (cellModel.title == SectionTitle.exprirationDate.rawValue) {
                let valuesArr = value?.split(separator: "-")
                // cell Date count
                let hasError = valuesArr?.count != 2 || (valuesArr?.first == "0" || valuesArr?.last == "0") || cvvValue.isEmpty == true
                cellsArray[cellModel.index].hasError = hasError
                errorCount = hasError ? errorCount + 1 : errorCount
            }else {
                let hasError = (value?.count == 0 || value == nil)
                cellsArray[cellModel.index].hasError = hasError
                errorCount = hasError ? errorCount + 1 : errorCount 
            }
            tableView.reloadRows(at: [IndexPath.init(row: cellModel.index, section: 0)], with: .automatic)
        }
        print(errorCount)
        if (errorCount == 0) {
            let param = cellsArray.reduce([String: String]()) { (dict, cellModel) -> [String: String] in
                var dict = dict
                if (cellModel.key == Keys.exprirationDate.rawValue) {
                    let kaysArr = cellModel.key.split(separator: "-")
                    let valuesArr = cellModel.value?.split(separator: "-")
                    dict[kaysArr.first?.description ?? ""] = valuesArr?.first?.description
                    dict[kaysArr.last?.description ?? ""] = valuesArr?.last?.description
                    dict[Keys.cvv.rawValue] = cvvValue
                }else if (cellModel.key == Keys.creditCard.rawValue)  {
                    let kaysArr = cellModel.key.split(separator: "-")
                    let valuesArr = cellModel.value?.split(separator: " ")
                    dict[kaysArr.first?.description ?? ""] = valuesArr?.first?.description
                    dict[kaysArr.last?.description ?? ""] = valuesArr?.last?.description
                }else{
                    dict[cellModel.key] = cellModel.value
                }
                return dict
            }
            self.creditCard(param: param)
        }
    }
    
    func Alert(_ title:String ,_ message:String){
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
      self.present(alert, animated: true)
    }
    
}

enum SectionTitle: String {
    case creditCard = "Credit Card Number"
    case exprirationDate = "Expiration Date"
    case cardHolder = "Cardholder Name"
    case address1 = "address_line1"
    case address2 = "address_line2"
    case addressCity = "City"
    case postalCode = "Postal Code"
    case province = "Province/Torritoy"
    case country = "Country"
}
enum Keys: String {
    case creditCard = "card[number]"
    case exprirationDate = "card[exp_year]-card[exp_month]"
    case cvv = "card[cvc]"
    case cardHolder = "card[name]"
    case address1 = "card[address_line1]"
    case address2 = "card[address_line2]"
    case addressCity = "card[address_city]"
    case postalCode = "card[address_zip]"
    case province = "card[address_state]"
    case country = "card[address_country]"
}
