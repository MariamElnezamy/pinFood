//
//  Menu.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-09.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class Menu: NSObject {
	typealias k = Constants.Menu
	
	public private(set) var currency: String = ""
	public private(set) var currencySymbol : String = ""
	public private(set) var sections: [String] = []
	public private(set) var itemsBySection: [String:[MenuItem]] = [:]
	
	// MARK: - Initialization
	
	init(currency: String) {
		self.currency = currency
		
		// TODO: We shouldn't change the global currency -- what if we have an order in CAD, but we're looking at a menu in USD?
		//	- We don't want to screw up the currency math for our order
		CurrencyManager.main.currency = currency
		
		
		super.init()
	}
	
	convenience init?(json: [String: Any]) {
		self.init(currency: json["currency"] as? String ?? "CAD")
		self.currencySymbol = json["currencySymbol"] as? String ?? "$"
		CurrencyManager.main.currencySymbol = json["currencySymbol"] as? String ?? "$"
		
		self.sections = []
		self.itemsBySection = [:]
		
		guard let sectionDicts = json["sections"] as? [[String: Any]] else {
			return
		}
		
		// For each section:
		var rDeals: [MenuItem] = [] // Special section for deals
		sectionDicts.forEach({ (sectionDict: [String: Any]) in
			if let name = sectionDict["name"] as? String {
				self.sections.append(name)
				var items: [MenuItem] = []
				let itemDicts = sectionDict["items"] as? [[String: Any]]
				
				// For each item in this section:
				itemDicts?.forEach({ (itemDict: [String: Any]) in
					if let item = MenuItem(json: itemDict) {
						item.sectionName = name
						items.append(item)
						if item.hasDeal, let itemCopy = item.rDealsCopy() {
							rDeals.append(itemCopy)
						}
					}
				})
				items.first?.isFirstInSection = true
				self.itemsBySection[name] = items
			}
		})
		rDeals.first?.isFirstInSection = true
		self.itemsBySection[k.rDealsName] = rDeals
	}
	
	
	// MARK: - Public Methods
	
	public func allSections(withRDeals: Bool = false) -> [String] {
//		let retVal = withRDeals ? ["RDeals"] + sections : sections
        let retVal = sections
		return retVal.filter({ (sectionName) -> Bool in
			return (itemsBySection[sectionName]?.count ?? 0) > 0
		})
	}
	
	public func numItems(withRDeals: Bool = false) -> Int {
		var retVal = 0
		for name in allSections(withRDeals: withRDeals) {
			retVal += itemsBySection[name]?.count ?? 0
		}
		return retVal
	}
	
	public func itemForIndex(_ index: Int, withRDeals: Bool = false) -> MenuItem? {
		var curIndex = index
		for name in allSections(withRDeals: withRDeals) {
			if let items = itemsBySection[name] {
				if curIndex < items.count {
					return items[curIndex]
				} else {
					curIndex -= items.count
				}
			}
		}
		return nil
	}
	
	public func firstItemIndexForSectionIndex(_ sectionIndex: Int, withRDeals: Bool = false) -> Int {
		var retVal = 0
		let sectionsNames = allSections(withRDeals: withRDeals)
		for i in 0..<sectionIndex {
			retVal += itemsBySection[sectionsNames[i]]?.count ?? 0
		}
		return min(retVal, numItems() - 1)
	}
	
	public func sectionForItemIndex(_ index: Int, withRDeals: Bool = false) -> Int {
		var curIndex = index
		let sectionsNames = allSections(withRDeals: withRDeals)
		
		for i in 0..<sectionsNames.count {
			if let items = itemsBySection[sectionsNames[i]] {
				if curIndex < items.count {
					return i
				} else {
					curIndex -= items.count
				}
			}
		}
		return 0
	}
	
	public func getAllMenuItems() -> [MenuItem]{
		var result : [MenuItem] = []
		for items in itemsBySection.values {
			result += items
		}
		return result
	}
	
	public func getMenuItemById(menuID: String) -> MenuItem? {
		let menus = getAllMenuItems() as [MenuItem]
		for item in menus {
			if item.itemID == menuID {
				return item
			}
		}
		return nil
		
	}
	
	public func getMenuItemByIdGivenList(menuID: String, theList: [MenuItem]) -> MenuItem? {
		for item in theList {
			if item.itemID == menuID {
				return item
			}
		}
		return nil
	}
}
