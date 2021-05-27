//
//  OrderItem.swift
//  Rescounts
//
//  Created by Monica Luo on 2019-03-28.
//  Copyright © 2019 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import UIKit

class OrderItem: NSObject{
	var rawItem : MenuItem
	var counter : Int = 0
	
	var umIDList: [String] = []
	
	init (item: MenuItem, counter: Int = 1) {
		self.rawItem = item
		self.counter = counter
		self.umIDList.append(item.umID)
		
		super.init()
	}
	
	public func getItem() -> MenuItem {
		return rawItem
	}
	
	public func getNum() -> Int {
		return counter
	}
	
	public func getSubtotal() -> Int {
        return rawItem.getSubtotal(isRDeal: rawItem.rDealsPrice != nil) * counter
	}
}

class OrderItemList: NSObject {
	var theList : [OrderItem] = []
	
	override init() {
	}
	
	init (menuList : [MenuItem]) {
		super.init()
		
		for item in menuList {
			self.addItem(item: item)
		}
	}
	
	public func addItem(item: MenuItem){
		for orderItem in theList {
			let theMenuItem = orderItem.rawItem
			if (compareName(A: theMenuItem, B: item) && compareNotes(A: theMenuItem, B: item) && compareOptions(A: theMenuItem, B: item)) {
				orderItem.counter += 1
				orderItem.umIDList.append(item.umID)
				return
			}
		}
		let newOrderItem = OrderItem(item: item)
		
		theList.append(newOrderItem)
		
	}
	
	public func refresh(menuOrder: [MenuItem]) {
		theList.removeAll()
		for item in menuOrder {
			self.addItem(item: item)
		}
	}
	
	public func count()->Int {
		return theList.count
	}
	
	public func getAtIndex(_ index: Int ) -> OrderItem{
		return theList[index]
	}
	
	
	// MARK - Private funcs
	//Step 1
	private func compareName(A: MenuItem , B: MenuItem) -> Bool {
		if A.title == B.title {
			return true
		} else {
			return false
		}
	}
	//Step 2
	private func compareOptions(A: MenuItem, B: MenuItem)-> Bool {
		
		let AList = A.options
		let BList = B.options
		
		if ((AList?.count ?? 0) != (BList?.count ?? 0)) {
			return false
		}
		
		if let a_list = AList {
			for item in a_list{
				let bItem : MenuItemOption? = searchForMenuItemOption (title: item.title, B: BList ?? [] )
				if bItem == nil {
					return false
				} else {
					//Check the selected value
					if (!compareSelectedValues(A: item.selectedNames(), B: bItem?.selectedNames() ?? [])) {
						return false
					}
				}
			}
		} else {
			return false
		}

		return true
	}
	//Step 3
	private func compareNotes (A: MenuItem, B: MenuItem) -> Bool {
		if A.requests == B.requests {
			return true
		} else {
			return false
		}
	}
	
	// MARKS - Helper func
	private func searchForMenuItemOption (title: String, B: [MenuItemOption]) -> MenuItemOption? {
		for item in B {
			if item.title == title {
				return item
			}
		}
		return nil
	}
	
	private func compareSelectedValues(A: [String], B: [String]) -> Bool {
		if A == B {
			return true
		} else  {
			return false
		}
	}
	
}
