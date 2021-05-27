//
//  AccountItem.swift
//  Rescounts
//
//  Created by Kittiphong Xayasane on 2018-08-15.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit



class MyAccountItem: NSObject {
	
	enum ValueType {
		case regular
		case phoneNumber
		case birthday
		case password
	}
	
	var title: String = ""
	var value: String = ""
	var valueType: ValueType = .regular
	var date: Date? = nil
	
	
	// MARK: - Initialization
	
	init(title: String = "", value: String = "", valueType: ValueType = .regular) {
		self.title = title
		self.value = value
		self.valueType = valueType
		
		super.init()
	}
}
