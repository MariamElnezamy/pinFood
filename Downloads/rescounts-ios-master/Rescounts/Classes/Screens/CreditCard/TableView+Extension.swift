//
//  TableViewCell+Extension.swift
//  Rescounts
//
//  Created by Admin on 18/05/2021.
//  Copyright © 2021 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

extension UITableView {
    override open func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UITextField || view is UITextView || view is UIButton {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
}

extension UITableViewCell{
    
   @objc func configureCell(data: Any){
    
    }
    @objc func showError(msgError: String){
        
    }
    @objc func HideError(){
        
    }
}
