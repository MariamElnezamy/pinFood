//
//  CreditCard+TableView.swift
//  Rescounts
//
//  Created by Admin on 17/05/2021.
//  Copyright © 2021 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation

extension CreditCardVC: UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = cellsArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: data.cellID)
        cell?.configureCell(data: data)
        cell?.selectionStyle = .none
        
        if let cellDate = cell as? DateViewTabelCell {
            cellDate.cvvValue = self.cvvValue
            cellDate.onYearButtonPress = { [weak self] in
                self?.dataArr = self?.yearsArr ?? []
                self?.showPicker(onRowSelected: {
                    [weak self](newValue) in
                    var data = self?.cellsArray[indexPath.row]
                    let valuesArray = data?.value?.split(separator: "-")
                    let value = valuesArray?.last ?? "0"
                    data?.value = "\(newValue)-\(value)"
                    self?.cellsArray[indexPath.row] = data ?? TableModel.init()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                })
            }
            cellDate.onMonthButtonPress = { [weak self] in
                self?.dataArr = self?.monthsArr ?? []
                self?.showPicker(onRowSelected: {
                    [weak self](newValue) in
                    var data = self?.cellsArray[indexPath.row]
                    let valuesArray = data?.value?.split(separator: "-")
                    let value = valuesArray?.first ?? "0"
                    data?.value = "\(value)-\(newValue)"
                    self?.cellsArray[indexPath.row] = data ?? TableModel.init()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                })
            }
            cellDate.onTextEdit = { [weak self] (text) in
                self?.cvvValue = text
            }
        }
        if let cellDropDown = cell as? DropDownTableCell {
            if (data.title == SectionTitle.province.rawValue) {
                cellDropDown.onButtonPress = { [weak self] in
                    self?.dataArr = self?.provinceArr ?? []
                    self?.showPicker(onRowSelected: {
                        [weak self](newValue) in
                        var data = self?.cellsArray[indexPath.row]
                        data?.value = "\(newValue)"
                        self?.cellsArray[indexPath.row] = data ?? TableModel.init()
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    })
                }
            }else if (data.title ==  SectionTitle.country.rawValue) {
                cellDropDown.onButtonPress = { [weak self] in
                    self?.dataArr = self?.countriesArr ?? []
                    self?.showPicker(onRowSelected: {
                        [weak self](newValue) in
                        var data = self?.cellsArray[indexPath.row]
                        data?.value = "\(newValue)"
                        self?.cellsArray[indexPath.row] = data ?? TableModel.init()
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                    })
                }
            }
        }
        if let textFieldCell = cell as? TextFieldLabelTableCell {
            textFieldCell.onTextEdit = { [weak self] (text) in
                
                var data = self?.cellsArray[indexPath.row]
                data?.value = "\(text)"
                self?.cellsArray[indexPath.row] = data ?? TableModel.init()
                cell?.configureCell(data: data ?? TableModel.init())
            }
            textFieldCell.onCameraPress = { [weak self] in
                self?.startScan()
            }
        }
        if let buttonCell = cell as? ButtonTableCell {
            buttonCell.onSaveButtonPress = { [weak self] in
                self?.addAdressRequest()
            }
            buttonCell.onCancelButtonPress = { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        }
        
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let data = cellsArray[indexPath.row]
        switch data.cellID {
        case "\(TextFieldLabelTableCell.self)":
            return data.hasError ? 100 : 90
        case "\(DateViewTabelCell.self)":
            return data.hasError ? 100 : 90
        case "\(DropDownTableCell.self)":
            return data.hasError ? 110 : 90
        default:
            return data.hasError ? 70 : 60
        }
    }
}


