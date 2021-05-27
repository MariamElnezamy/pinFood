//
//  Card.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-09-19.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation

class Card : NSObject {
	var brand : String = ""
	var last4 : String = ""
	var expiryMonth : Int = 0
	var expiryYear : Int = 0
	
	init(brand : String, last4 : String, expiryMonth : Int, expiryYear : Int){
		self.brand = brand
		self.last4 = last4
		self.expiryMonth = expiryMonth
		self.expiryYear = expiryYear
		
		super.init()
	}
	
	convenience init? (json: [String: Any]) {
		let brand : String = json["brand"] as? String ?? ""
		let last4 : String = json["last4"] as? String ?? ""
		let expiryMonth : Int = (json["expiryMonth"] as? NSNumber)?.intValue ?? 0
		let expiryYear : Int = (json["expiryYear"] as? NSNumber)?.intValue ?? 0
		self.init(brand: brand, last4: last4, expiryMonth : expiryMonth, expiryYear: expiryYear)
	}
}
