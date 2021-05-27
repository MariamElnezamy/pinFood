//
//  CreitCard+Picker.swift
//  Rescounts
//
//  Created by Admin on 19/05/2021.
//  Copyright © 2021 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation


// Picker View
extension CreditCardVC : UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArr.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return (dataArr[row] as AnyObject).description
    }
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let title = (dataArr[row] as AnyObject).description
        
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            pickerLabel?.textAlignment = .center
        }
        
        pickerLabel?.text = title
        pickerLabel?.textColor = .darkGray
        
        return pickerLabel!
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let title = (dataArr[row] as AnyObject).description
        self.onRowSelected?(title ?? "")
        hidePicker()
    }
    
}
