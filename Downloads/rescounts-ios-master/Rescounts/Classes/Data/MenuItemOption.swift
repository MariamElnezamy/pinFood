//
//  MenuItemOption.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-08-25.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class MenuItemOption: NSObject, NSCopying {
	typealias MenuItemOptionValue = (name: String, cost: Int)
	
	var optionID : String = ""
	var title : String  = ""
	var price: Int = 0
	var values : [MenuItemOptionValue] = []
	var limit : Int? = 0
	var minimum : Int? = 0
	var selectedIndices: Set<Int> = [] // TODO: use this instead of selected_values (delete that one)
	var representsBasePrice : Bool = false
	
	
	// MARK: - Initializers
	
	init(id optionID: String, title: String, price : Int, values: [MenuItemOptionValue], limit : Int? = 0, minimum : Int? = 0, basePrice: Bool = false  ){
		self.optionID = optionID
		self.title = title
		self.price = price
		self.limit = limit
		self.minimum = minimum
		self.values = values
		self.representsBasePrice = basePrice
		
		super.init()
	}
	
	convenience init?(json: [String: Any]) {
		var newValues: [MenuItemOptionValue] = []
		(json["values"] as? [[String : Any]])?.forEach { (value) in
			if let name = value["name"] as? String, let cost = value["cost"] as? Int {
				newValues.append((name, cost))
			}
		}
		
		if let optionId = json["id"] as? String, let title = json["name"] as? String {
			self.init(id: optionId, title: title,
					  price:(json["cost"] as? NSNumber)?.intValue ?? 0,
					  values:  newValues)
			
			if let limitNum = json ["limit"] as? Int, limitNum > 0 {
				self.limit = limitNum
			}
			if let minimumNum = json["minimum"] as? Int  {
				self.minimum = minimumNum
			}
			
		} else {
			return nil
		}
	}
	
	
	// MARK: - Public Methods
	
	public func selected(key : String) {
		for (i,value) in values.enumerated() {
			if value.name == key {
				selectedIndices.insert(i)
			}
		}
	}
	
	public func removeOption(key : String) {
		for (i,value) in values.enumerated() {
			if value.name == key {
				selectedIndices.remove(i)
			}
		}
	}
	
	public func getSubtotal() -> Int {
		var subtotal : Int = 0
		for index in selectedIndices {
			if (0..<values.count) ~= index {
				subtotal += values[index].cost
			}
		}
		
		return subtotal
	}
	
	public func selectedValues() -> [MenuItemOptionValue] {
		var retVal: [MenuItemOptionValue] = []
		for (i, value) in values.enumerated() {
			if selectedIndices.contains(i) {
				retVal.append(value)
			}
		}
		return retVal
	}
	
	public func selectedNames() -> [String] {
		return selectedValues().map { $0.name }
	}
	
	public func valueForIndex(_ index: Int) -> MenuItemOptionValue? {
		if (0..<values.count) ~= index {
			return values[index]
		}
		return nil
	}
	
	public func hasNonFreeItem() -> Bool {
		for value in values {
			if value.cost > 0 {
				return true
			}
		}
		return false
	}
	
	func copy(with zong: NSZone? = nil) -> Any {
		let newItemOption : MenuItemOption = MenuItemOption(id: self.optionID, title: self.title, price: self.price, values: self.values, limit: self.limit, minimum: self.minimum, basePrice: self.representsBasePrice)
		
		return newItemOption
	}
}
