//
//  OrderService.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-08-29.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import Alamofire

class OrderService: BaseService {
	typealias OrderCallback = (String?, OrderError?) -> Void
	typealias GetOrderCallback = (_ orderID: String?, _ costs: (cost: Int, tax: Int, rDealsDiscount: Int)?, _ approved: Bool?, _ error: OrderError?, _ declinedItems: [[String: Any]]?) -> Void
	
	static func submitOrder(tableID: String, callback: @escaping OrderCallback) {
		guard tableID.count > 0, let url = urlWith(path: "tables/\(tableID)/orders") else {
			print ("Order error: Invalid JSON.")
			callback(nil, nil)
			return
		}

		var orderModel : [String: Any] = OrderManager.main.orders.getJsonOrder()
		orderModel["token"] = AccountManager.main.user?.stripeToken?.tokenId
		
		let headers: HTTPHeaders = [
			"Content-Type" : "application/json",
			"Authorization" : AccountManager.main.tokenArg
		]
		
		Alamofire.request(url, method: .post, parameters: orderModel, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
			guard let httpResponse = response.response else {
				print ("ERROR SUBMITTING ORDER: Could not reach server.")
				callback(nil, submitOrderError(l10n("couldNotReachServer")))
				return
			}
			printStatus("Submit Order", httpResponse.statusCode)
			
			guard let json = response.result.value as? [String: Any] else {
				print ("ERROR SUBMITTING ORDER RESPONSE: Invalid JSON.")
				callback(nil, submitOrderError())
				return
			}
			
			if 200 ... 299 ~= httpResponse.statusCode {
				printStatus("Get Order Response: ", httpResponse.statusCode)
				if let orderID = json["id"] as? String, orderID.count > 0 {
					callback(orderID, nil)
					print("Get Order ID, orderid is \(orderID)")
				} else {
					callback(nil, submitOrderError())
					print("Don't have an Order ID yet.")
				}
			} else {
				if let errorMess = json["error"] as? String {
					print(errorMess)
					callback(nil, submitOrderError(errorMess))
					return
				}
				callback(nil, submitOrderError())
				return
			}
			
		}
		
		func submitOrderError(_ desc: String? = nil, code: Int = 0) -> OrderError {
			let errorDescription = desc ?? l10n("submitOrderGeneric")
			return OrderError.submitError(message: errorDescription)
		}
	}
	
	static func getOrder(orderID: String , callback: @escaping GetOrderCallback) {
		guard orderID.count > 0, let url = urlWith(path: "orders/\(orderID)") else {
			print ("GET ORDER ERROR: Invalid URL")
			callback(nil, nil, nil, nil, nil)
			return
		}
		
		let headers: HTTPHeaders = [
			"Content-Type" : "application/json",
			"Authorization": AccountManager.main.tokenArg
		]
		
		Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
			guard let httpResponse = response.response else {
				print ("GET ORDER ERROR: Could not reach server")
				callback(nil, nil, nil, orderServiceError(l10n("couldNotReachServer")), nil)
				return
			}
			
			guard let json = response.result.value as? [String: Any] else {
				print ("GET ORDER ERROR: Invalid JSON.")
				callback(nil, nil, nil, orderServiceError(), nil)
				return
			}
			
			if let orderID = json["id"] as? String, 200 ... 299 ~= httpResponse.statusCode  {
				printStatus("Get Order Reponse: ", httpResponse.statusCode)
				if let approved = json["approved"] as? Bool, approved {
					let costs = ((json["cost"] as? NSNumber)?.intValue ?? 0, (json["taxAmount"] as? NSNumber)?.intValue ?? 0, (json["rdealDiscount"] as? NSNumber)?.intValue ?? 0)
					callback(orderID, costs, approved, nil, nil)
					print("Get Order \(orderID): approved!")
				} else if(isDeclined(json:json)) {
                    callback(orderID, nil, false, nil, collectDeclinedItem(json: json))
					print("Get Order \(orderID): declined!")
				} else {
					callback(orderID, nil, nil, orderServiceError(), nil)
					print("Get Order \(orderID): not yet approved...")
				}
				
			} else {
				callback(nil, nil, nil, orderServiceError(), nil)
				return
			}
		}
	}
	
	static func isDeclined(json: [String: Any]) -> Bool {
		if let items = json["items"] as? [[String: Any]] {
			for item in items {
				if item["declineReason"] != nil {
					return true
				}
			}
		}
		return false
	}
	
    static func collectDeclinedItem(json: [String: Any]) -> [[String: Any]] {
        var result : [[String: Any]] = []
		if let items = json["items"] as? [[String: Any]] {
			for item in items {
				if item["declineReason"] != nil {
					result.append(item)
				}
			}
		}
		return result
	}
	
	static func orderServiceError(_ desc: String? = nil, code: Int = 0) -> OrderError {
		let errorDescription = desc ?? "Could not fetch order, check your internet connection and try again."
		return OrderError.fetchError(message: errorDescription)
	}
	
	// Get a brand new menu items and add pre selected menu item into the order manager list
	//	- mutates the OrderManager's current order
	static func getOpenOrderForUser(resID: String, json: [String: Any], callback: @escaping RescountsServiceCallback) {
		MenuService.fetchMenu(restaurantID: resID) { menu in
			guard let orderModel = json["orders"] as? [[String: Any]] else {
				callback(false)
				return
			}
			
			let menuItemList = menu?.getAllMenuItems()
			
			OrderManager.main.orders.clearItems()
			
			for order in orderModel {
				if let paid = order["paid"] as? Bool, !paid {
					if let items = order["items"] as? [[String: Any]] {
						let approved = order["approved"] as? Bool ?? false
						if approved, let orderID = order["id"] as? String, let cost = (order["cost"] as? NSNumber)?.intValue, let tax = (order["taxAmount"] as? NSNumber)?.intValue {
							let discount = (order["rdealDiscount"] as? NSNumber)?.intValue ?? 0
							OrderManager.main.orders.add(cost: cost, tax: tax, discount: discount, orderID: orderID)
						}
						for singleItem in items {
							let itemID = singleItem["itemID"] as? String ?? ""
							
							if let singleMenuItem = menu?.getMenuItemByIdGivenList(menuID: itemID, theList: menuItemList ?? []) {
								if let singleMenuItemCopy = (singleMenuItem).copy() as? MenuItem {
									//attach selected options to the singleMenuItem
									singleMenuItemCopy.addSelectedOptions(optionsInput: singleItem["options"] as? [String :[String]] ?? [:])
									singleMenuItemCopy.requests = singleItem["note"] as? String ?? ""
									if approved {
										//Add single item to the confirmed list
										OrderManager.main.orders.addItemToConfirmed(singleMenuItemCopy)
										
									} else {
										//Add single item to the pending list
										OrderManager.main.orders.addItem(singleMenuItemCopy)
										OrderManager.main.orders.orderID = order["id"] as? String ?? ""
									}
								}
							}
						}
					}
				}
			}
			
			callback(true)
		}// end of Menu Service

	}
}

public enum OrderError: Error {
	case submitError (message: String?)
	case fetchError (message: String?)
}

extension OrderError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .submitError (message: let message):
			return l10n(message ?? "Could not submit. Check your internet connection and try again.")
		case .fetchError (message: let message):
			return l10n(message ?? "Could not fetch order. Check your internet connection and try again.")
		}
	}
}
