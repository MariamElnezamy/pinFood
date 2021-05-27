//
//  MenuItem.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-09.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class MenuItem: NSObject, NSCopying {
	var itemID:    String = ""
	var title:     String = ""
	var details:   String = ""
	var requests:  String = ""
	var nutrition: String = ""
	var price:     Int  = 0
	var rDealsPrice: Int?  = nil
	var calories:  Int  = 0
	var taxRate:   Float? = nil
	var thumbnail: URL?   = nil
	var options: [MenuItemOption]? = []
	var umID: 	   String = "" // This is a unique menu id used only when the menuitem is added to an order.
	var alcoholic: Bool   = false
	
	// Transient properties
	internal var isFirstInSection = false
	internal var sectionName: String = ""
	
	var hasThumbnail: Bool {
		get { return thumbnail != nil }
	}
	var hasDeal: Bool { return rDealsPrice != nil }
	var rDealsPriceOrPrice: Int { return rDealsPrice ?? price}
	
	var displayPrice: String = ""
	var rDealsDisplayPrice: String = ""
	
	
	// MARK: - Initialization
	
	init(id itemID: String, title: String, price: Int, details: String = "", nutrition: String = "", thumbnail: URL? = nil , options: [MenuItemOption]? = [], requests: String = "", alcoholic : Bool = false, calories : Int = 0) {
		self.itemID = itemID
		self.title = title
		self.details = details
		self.price = price
		self.thumbnail = thumbnail
		self.options = options
		self.requests = requests
		self.alcoholic = alcoholic
		self.calories = calories
		self.nutrition = nutrition
		
		self.umID = NSUUID().uuidString
		
		super.init()
	}
	
	convenience init?(json: [String: Any]) {
		guard let itemID = json["id"] as? String, let title = json["name"] as? String else {
			return nil
		}
		
		self.init(id: itemID,
				  title: title,
				  price: (json["cost"] as? NSNumber)?.intValue ?? 0,
				  details: (json["description"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines))
		
		var newThumbnailURL: URL? = nil
		if let thumbnailStr = json["photo"] as? String {
			newThumbnailURL = URL(string: thumbnailStr)
		}
		
		let optionsList = json["options"] as? [[String:Any]]
		optionsList?.forEach { (option : [String : Any]) in
			if let optionItem = MenuItemOption(json: option) {
				self.options?.append(optionItem)
			}
		}
		let dealPrice = (json["rdealActive"] as? NSNumber)?.boolValue == true
			? (json["rdealPrice"] as? NSNumber)?.intValue
			: nil
		
		updateWith(rDealsPrice: dealPrice,
				   alco: json["alcoholic"] as? Bool ?? false,
				   nutrition: json["nutrition"] as? String ?? "",
				   calories: json["calories"] as? Int ?? 0,
				   taxRate: (json["flatTaxRate"] as? NSNumber)?.floatValue,
				   thumbnail: newThumbnailURL)
	}
	
	private func updateWith(rDealsPrice: Int?, alco: Bool, nutrition: String, calories: Int, taxRate: Float?, thumbnail: URL?) {
		self.rDealsPrice = rDealsPrice
		self.alcoholic = alco
		self.nutrition = nutrition
		self.calories = calories
		self.taxRate = taxRate
		self.thumbnail = thumbnail
		
		var newPrice = price
		var newRDealsPrice = rDealsPrice ?? 0
		
		if let maxOfMinsOptionPrice = maxOfMinsOptionPrice(), newPrice == 0 {
			newPrice = maxOfMinsOptionPrice
			newRDealsPrice = newPrice // Since the cost is on the option (not the item), rDeals wouldn't apply to this item
			
			//Mark the option for base price
			markBaseOption(value: newPrice)
		}
		
		self.displayPrice = newPrice > 0 ? CurrencyManager.main.getCost(cost: newPrice) : "free"
		if (hasDeal) {
			self.rDealsDisplayPrice = newRDealsPrice > 0 ? CurrencyManager.main.getCost(cost: newRDealsPrice) : "free"
		}
	}
	
	public func getSubtotal(isRDeal: Bool) -> Int {
		var optionTotal : Int = isRDeal ? rDealsPriceOrPrice : price
		for singleOption in options ?? [] {
			optionTotal = optionTotal + singleOption.getSubtotal()
		}
		return optionTotal
	}
	
	public func getDiscount() -> Int {
		return price - rDealsPriceOrPrice
	}
	
	//This func is used for fetching the same orders from network
	public func addSelectedOptions(optionsInput: [String : [String]]){
		for sectionName in optionsInput.keys {
			for optionItem in options ?? [] {
				if optionItem.title == sectionName {
					for selectedOption in optionsInput[sectionName] ?? [] {
						optionItem.selected(key: selectedOption)
					}
				}
			}
		}
	}
	
	public func assignRequests(_ info: String = "") {
		self.requests = info
	}
	
	 func copy(with zone: NSZone? = nil) -> Any {
		var newOptions : [MenuItemOption] = []
		if self.options != nil {
			for singleOption in self.options ?? [] {
				if let theNew = singleOption.copy() as? MenuItemOption {
					newOptions.append(theNew)
				} else {
					print("copy item failed")
				}
			}
		}
		
		let newItem : MenuItem = MenuItem(id: self.itemID, title: self.title, price: self.price, details: self.details, nutrition: self.nutrition,thumbnail: self.thumbnail, options: newOptions, requests: self.requests, alcoholic: self.alcoholic, calories : self.calories)
		newItem.updateWith(rDealsPrice: rDealsPrice,
						   alco: alcoholic,
						   nutrition: nutrition,
						   calories: calories,
						   taxRate: taxRate,
						   thumbnail: thumbnail)
		
		return newItem
	}
	
	public func rDealsCopy() -> MenuItem? {
		guard let retVal = copy() as? MenuItem else {
			return nil
		}
		
		retVal.sectionName = Constants.Menu.rDealsName
		
		return retVal
	}
	

	// MARK: - Private Helpers
	private func maxOfMinsOptionPrice() -> Int? {
		var maxOfMinsOptionsArray: [Int] = []
		for optionCategory in options ?? [] {
			var maxOfMinsOptionItemPrice: Int = (optionCategory.values.count > 0) ? .max : 0  // If there are no values, we don't want to use .max!
			for optionItem in optionCategory.values {
				if optionItem.cost < maxOfMinsOptionItemPrice {
					maxOfMinsOptionItemPrice = optionItem.cost
				}
			}
			maxOfMinsOptionsArray.append(maxOfMinsOptionItemPrice)
		}

		return maxOfMinsOptionsArray.max()
	}
	
	private func markBaseOption(value: Int) {
		for optionCategory in options ?? [] {
			var maxOfMinsOptionItemPrice: Int = (optionCategory.values.count > 0) ? .max : 0  // If there are no values, we don't want to use .max!
			for optionItem in optionCategory.values {
				if optionItem.cost < maxOfMinsOptionItemPrice {
					maxOfMinsOptionItemPrice = optionItem.cost
				}
			}
			if maxOfMinsOptionItemPrice == value {
				optionCategory.representsBasePrice = true
				return;
			}
		}
	}
}
