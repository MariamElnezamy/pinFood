//
//  TableModel.swift
//  Rescounts
//
//  Created by Admin on 18/05/2021.
//  Copyright © 2021 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation

struct TableModel {
    
    var cellID: String = ""
    var key: String = ""
    var value: String?
    var title: String = ""
    var hasError = false
    var msgError: String? = ""
    var isRequired = false
    var index = 0
    init(cellID: String, key: String, value: String?, title: String,msgError: String?, isRequired: Bool ){
        self.cellID = cellID
        self.key = key
        self.value = value
        self.title = title
        self.msgError = msgError
        self.isRequired = isRequired
    }
    init(){
        
    }
}
