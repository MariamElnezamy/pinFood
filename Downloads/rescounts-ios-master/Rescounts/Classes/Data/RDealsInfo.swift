//
//  RDealsInfo.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2019-06-10.
//  Copyright © 2019 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation

enum RDealsType {
	case dollar, percent
}


class RDealsInfo: NSObject {
	let dealType: RDealsType
	let amount: Int  // For 'dollar' type: the flat amount in cents, for 'percent' type: the percentage discount * 100  (e.g. 15% == 1500)
	let numItems: Int
	let fee: Int
	
	init(type : RDealsType, amount: Int, numItems: Int, fee: Int) {
		self.dealType = type
		self.amount = amount
		self.numItems = numItems
		self.fee = fee
		
		super.init()
	}
	
	convenience init? (json: [String: Any]) {
		// TODO: Fix these json keys once backend is deployed
		
		guard let typeString: String = json["rdealsType"] as? String,
			  let amount:     Int   = (json["rdealsValue"] as? NSNumber)?.intValue,
			  let fee:        Int   = (json["rdealsFee"] as? NSNumber)?.intValue else
		{
				return nil
		}
		let numItems: Int = (json["rdealsAmount"] as? NSNumber)?.intValue ?? 0
		
		let type: RDealsType = typeString == "dollar" ? .dollar : .percent
		
		self.init(type: type, amount: amount, numItems: numItems, fee: fee)
	}
	
	public var displayAmount: String {
		if dealType == .dollar {
			return CurrencyManager.main.getCost(cost: amount, hideDecimals: (amount % 100 == 0)) // TODO: instead of % 100, use currency manager to figure out the number of minor units in a major unit
		} else {
			let decimalPlaces = (amount % 100 == 0) ? 0 : 1
			let formatString = "%.\(decimalPlaces)f%%"
			return String(format:formatString, Float(amount)/100)
		}
	}
}
