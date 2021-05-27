//
//  UserOrder.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-08-17.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//
//  This class actually combines all orders into this one object. If you have a problem with that, talk to Monica.  :)

import UIKit

class UserOrder: NSObject {
	public var restaurantID: String = ""
	public var orderID : String = "" // This is actually the ID of the last order
	public var discountInfo: Int = 0
	public var declinedReason : String = l10n("tableNoDeclinedDefault")
	public var confirmedItems: [MenuItem] = []
	public var pendingItems: [MenuItem] = []
	private var orderCosts: [String: (cost: Int, tax: Int, discount: Int)] = [:]
	
	public var useLoyaltyBonus: Bool = true {
		didSet {
			NotificationCenter.default.post(name: .orderChanged, object: self)
		}
	}
	
	
	// MARK: - Public Methods
	
	public var hasAnyItems: Bool {
		return hasPendingItems || hasConfirmedItems
	}
	
	public var hasPendingItems: Bool {
		return pendingItems.count > 0
	}
	
	public var hasConfirmedItems: Bool {
		return confirmedItems.count > 0
	}
	
	//Adding one more MenuItem into pendingItems
	public func addItem(_ item: MenuItem) {
		pendingItems.append(item)
		NotificationCenter.default.post(name: .orderChanged, object: self)
	}
	
	//Sometime, we need to add a single menu item strickly into confirmed list
	public func addItemToConfirmed(_ item : MenuItem){
		confirmedItems.append(item)
		NotificationCenter.default.post(name: .orderChanged, object: self)
	}
	//Removing one MenuItem
	public func removeItem(_ item: MenuItem) {
		for(index, element) in pendingItems.enumerated(){
			if(element.umID == item.umID){
				pendingItems.remove(at: index)
				NotificationCenter.default.post(name: .orderChanged, object: self)
				return;
			}
		}
	}
	
	public func removeItem(_ umID: String) {
		for (index, element) in pendingItems.enumerated() {
			if (element.umID == umID) {
				pendingItems.remove(at: index)
				NotificationCenter.default.post(name: .orderChanged, object: self)
				return;
			}
		}
	}
	
	//This func will be called when there is a declined order.
	//Id is the menu item's itemID which we will get from json model
	//With a combination of menu item id and options items, we should be able to know the correct menuitem
	//Otherwise, we should send menu's umid to server as well.
    public func removeItemByID(_ id : String, menuOptionItems: [String]) {
        for(index, element) in pendingItems.enumerated() {

            // Get all menu option items (sides, beverages, etc)
            var optionItems: [String] = []
            element.options?.forEach { (optionSubSection) in
				optionItems.append(contentsOf: optionSubSection.selectedNames())
            }

            if (element.itemID == id && optionItems == menuOptionItems) {
                pendingItems.remove(at: index)
                return;
            }
        }
    }

	//Move all pending Items into confirmed items and clean all pending items
	public func confirmItems() {
		for item in pendingItems{
			confirmedItems.append(item)
		}
		pendingItems.removeAll()
		NotificationCenter.default.post(name: .orderChanged, object: self)
	}
	
	// Clear all confirmed and pending items. This should only be called if we KNOW there are no pending/confirmed orders to handle (e.g. if we cancel or close the table)
	// TODO: Make sure this is getting called from the 'endTable' user flow. Probably via OrderManager.main.clearTable().
	public func clearItems() {
		confirmedItems.removeAll()
		pendingItems.removeAll()
		orderCosts.removeAll()
		restaurantID = ""
		orderID = ""
	}
	
	public func assignResturantId(_ id: String){
		self.restaurantID = id
	}
	
	public func hasFirstTimeBonus() -> Bool {
		return (AccountManager.main.user?.firstOrderBonus ?? false) /*&& (getRawSubtotal() >= Constants.Order.signUpBonusBoundary)*/
	}
	
	public func containsAlcohol() -> Bool {
		for item in confirmedItems {
			if item.alcoholic {
				return true
			}
		}
		for item in pendingItems {
			if item.alcoholic {
				return true
			}
		}
		return false
	}
	
	public func getFirstTimeBonus() -> Int {
		// TODO: determine this availability/value properly
		return (hasFirstTimeBonus() && (getRawSubtotal() >= Constants.Order.signUpBonusBoundary)) ? 500 : 0
	}
	
	public func getLoyaltyBonus() -> Int {
		return self.useLoyaltyBonus ? (AccountManager.main.user?.topEligibleLoyaltyTier?.value ?? 0) : 0
	}
	
	public var loyaltyInfo: User.LoyaltyPointInfo? {
		return AccountManager.main.user?.topEligibleLoyaltyTier
	}
	
	public func getPreAuthorizedSubtotal() -> Int { // This is used for second or more order request
		var subtotal : Int = 0
		for item in pendingItems {
            subtotal += item.getSubtotal(isRDeal: item.rDealsPrice != nil)
		}
		let tax = applyTax(OrderManager.main.currentRestaurant?.taxRate ?? 0.13, to: subtotal)
		return subtotal + tax
	}
	
	public func getRawSubtotal() -> Int {
		var subtotal : Int = 0
		for (_, value) in orderCosts {
			subtotal += value.cost
		}
		
		for item in pendingItems {
            subtotal += item.getSubtotal(isRDeal:item.rDealsPrice != nil)
		}
		
		return subtotal
	}
	
	public func getRDealsDiscount() -> Int {
		var discount : Int = 0
		for (_, value) in orderCosts {
			discount += value.discount
		}
		
		for item in pendingItems {
			discount += item.getDiscount()
		}
		
		return discount
	}
	
    public func getSubtotal(isRdeals: Bool) -> Int {
		var subtotal = getRawSubtotal()
		
		if !(isRdeals) {
			subtotal -= getFirstTimeBonus()
			subtotal -= getLoyaltyBonus()
		}
		subtotal -= discountInfo
		
		if subtotal < 0 {
			subtotal = 0
		}
		
		return subtotal
	}
	
	// Because discounts will invalidate the tax values we get from the server, calculate this locally
	public func getTax(isRdeal: Bool) -> Int {
		// Because we want to apply loyalty discouns to subtotal BEFORE applying tax, we can't apply tax to items directly anymore, and so we lose the per-item tax logic
//		var tax : Int = 0
//
//		for item in confirmedItems {
//			tax += Int(item.getSubtotal() * (item.taxRate ?? OrderManager.main.currentRestaurant?.taxRate ?? 0))
//		}
//
//		for item in pendingItems {
//			tax += Int(item.getSubtotal() * (item.taxRate ?? OrderManager.main.currentRestaurant?.taxRate ?? 0))
//		}
		
        if isRdeal {
            return applyTax(OrderManager.main.currentRestaurant?.taxRate ?? 0, to: getSubtotal(isRdeals: isRdeal) + OrderManager.main.rDealsFee)

        }
        return applyTax(OrderManager.main.currentRestaurant?.taxRate ?? 0, to: getSubtotal(isRdeals: isRdeal))

	}
	
	public func getTip() -> Int {
		return (OrderManager.main.currentTable?.shouldApplyTip == true)
			? applyTax(OrderManager.main.currentRestaurant?.defaultTip ?? Constants.User.defaultTip, to: getRawSubtotal())
			: 0
	}
	
	public func getTotal(isRdeal: Bool) -> Int {
		return getTotal(withTip: getTip() ,isRdeal: isRdeal)
	}
	
    public func getTotal(withTip: Int, isRdeal: Bool = true) -> Int {
        if isRdeal {
            return getSubtotal(isRdeals: isRdeal) + getTax(isRdeal: isRdeal) + withTip + OrderManager.main.rDealsFee
        }
        return getSubtotal(isRdeals: isRdeal) + getTax(isRdeal: isRdeal) + withTip

	}
	
	public func add(cost: Int, tax: Int, discount: Int, orderID: String) {
		orderCosts[orderID] = (cost, tax, discount)
	}
	
	public func removeCost(orderID: String) {
		orderCosts.removeValue(forKey: orderID)
	}
	
	
	// MARK: - Private Helpers
	
	private func applyTax(_ tax: Float, to amount: Int) -> Int {
		return CurrencyManager.main.convertIntForMoney(money: Float(amount) * tax )
	}
	
	
	//MARK: - json code
	
	public func getJsonOptions(item:MenuItem)->[String : [String]]{

		var result : [String: [String]] = [:]
		for singleItem in item.options ?? [] {
			let names = singleItem.selectedNames()
			if (names.count > 0) {
				result[singleItem.title] = singleItem.selectedNames()
			}
		}
		
		return result
		
	}
	
	public func getJsonItems() -> [[String : Any]]{
		var result : [[String: Any]] = []
		for item in pendingItems {
			let singleItem: [String: Any] = ["itemID" : item.itemID,
											 "options" : getJsonOptions(item: item),
											 "note" : item.requests]
			result.append(singleItem)
		}
		return result
	}
	
	public func getJsonOrder() -> [String: Any]{

		let result : [String: Any] = ["items": getJsonItems()]
		return result
	}
	
}
