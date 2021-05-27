//
//  TableService.swift
//  Rescounts
//
//  Created by Kit Xayasane on 2018-08-26.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import Alamofire

class TableService: BaseService {

	static func getDiscount(tableID: String, callback: @escaping (NSError?, Int?) -> Void) {
		guard let url = urlWith(path: "tables/\(tableID)") else {
			print("GET TABLE ERROR: Invalid URL.")
			callback(nil, nil)
			return
		}

		let headers: HTTPHeaders = [
			"Content-Type": "application/json",
			"Authorization": AccountManager.main.tokenArg
		]

		Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
			guard let httpResponse = response.response else {
				print ("GET TABLE ERROR: Could not reach server.")
				callback(tableServiceError(l10n("couldNotReachServer")), nil)
				return
			}

			guard let json = response.result.value as? [String: Any] else {
				print ("GET TABLE ERROR: Invalid JSON.")
				callback( tableServiceError(), nil)
				return
			}

			if 200 ... 299 ~= httpResponse.statusCode {
				printStatus("Get Table Reponse: ", httpResponse.statusCode)
				if let customersBlock = json["customers"] as? [[String : Any]] {
					if let customer = customersBlock.first {
						let discount = customer["restaurantDiscount"] as? Int ?? 0
						callback(nil, discount)
						return
					}
				}
			} else {
				callback(tableServiceError(), nil)
				return
			}
		}
	}
	static func getTableStatus(tableID: String, callback: @escaping (Bool?, NSError?, String?) -> Void) {

		guard let url = urlWith(path:"tables/\(tableID)") else {
			print ("GET TABLE ERROR: Invalid URL.")
			callback(nil, nil, nil)
			return
		}

		let headers: HTTPHeaders = [
			"Content-Type": "application/json",
			"Authorization": AccountManager.main.tokenArg
		]

		Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
			guard let httpResponse = response.response else {
				print ("GET TABLE ERROR: Could not reach server.")
				callback(nil, tableServiceError(l10n("couldNotReachServer")),nil)
				return
			}

			guard let json = response.result.value as? [String: Any] else {
				print ("GET TABLE ERROR: Invalid JSON.")
				callback(nil, tableServiceError(),nil)
				return
			}

			if 200 ... 299 ~= httpResponse.statusCode  {
				printStatus("Get Table Reponse: ", httpResponse.statusCode)
				if let approved = json["approved"] as? Bool, approved {
					print("Get Table \(tableID): approved!")
					let waiter = Waiter(json: json["waiter"] as? [String:Any] ?? [:])
					//UNREVIEWED TAG
					//This is for UNREVIEWED table
					if let closed = json["closedAt"] as? String, closed.count > 0 {
						OrderManager.main.unreviewedTable.Waiter = waiter?.firstName
						OrderManager.main.unreviewedTable.RestaurantID = json["restaurantID"] as? String
						if let orders = json["orders"] as? [[String : Any]] {
							OrderManager.main.unreviewedTable.TotalPrice = getTotalForOrders(orders: orders)
							OrderManager.main.unreviewedTable.Tip = getTipForOrders(orders: orders)
						}
						callback(approved, nil, nil)
					} else { //This is an open table
						OrderManager.main.currentTable?.waiter = waiter ?? Waiter() //<- This is important to assign a waiter, do now remove this line!
						OrderManager.main.currentTable?.joinCode = json["shortID"] as? String ?? ""
						if let customersBlock = json["customers"] as? [[String : Any]] {
							if let customer = customersBlock.first {
								let discount = customer["restaurantDiscount"] as? Int ?? 0
								OrderManager.main.orders.discountInfo = discount
								let piOrderCode = customer["piOrderCode"] as? String ?? ""
								OrderManager.main.currentTable?.piOrderNum = piOrderCode
							}
						}
						callback(approved, nil, nil)
					}
				} else {
					if let response  = json["approvedAt"] as? String, response.count > 0 {
						//The table has declined due to ......
						print(response)
						let reason = json["approvedNote"] as? String
						OrderManager.main.orders.declinedReason = reason ?? l10n("noTableAvailable")
						callback(false, nil, "Declined") //currently there is no specific reason for declined request.
					} else if let response2 = json["alternateSeatingAt"] as? String, response2.count > 0 {
						//The table has been rescueduled
						print(response2)
						callback(false, nil, response2)
					} else {
						//Should keep polling, the table requirement has been responsed
						callback(nil, tableServiceError(), nil)
						print("Get Table \(tableID): not yet approved...")
					}
				}

			} else {
				if ( httpResponse.statusCode == 404  && HoursManager.isAutoCancelTimerRunning) {
					//Table should be auto canceled
					callback(false, nil , "Canceled")
				}
				callback(nil, tableServiceError() , nil)
				return
			}
		}
	}
	
	
	static func getOpenTableForUser(callback: @escaping (RestaurantTable?, String?)->Void) {
		guard let url = urlWith(path:"users/\(AccountManager.main.user?.userID ?? "")/tables/open") else {
			print ("GET OPEN TABLE ERROR: Invalid URL")
			callback(nil, nil)
			return
		}
		
		let headers: HTTPHeaders = [
			"Content-Type": "application/json",
			"Authorization": AccountManager.main.tokenArg
		]
		
		Alamofire.request(url, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
			guard let httpResponse = response.response else {
				print ("OPEN TABLE ERROR: Could not reach server.")
				callback(nil, nil)
				return
			}
			printStatus("Open Table", httpResponse.statusCode)
			
			guard let json = response.result.value as? [String: Any] else {
				print ("OPEN TABLE ERROR: Invalid JSON.")
				callback(nil, nil)
				return
			}
			
			/* There really, really, really shouldn't be more than one table here */
			guard let tables = json["tables"] as? [[String:Any]],
				  let tableJson = tables.first,
				  let table = RestaurantTable(json: tableJson) else
			{
				callback(nil, nil)
				return
			}
			
			let waiter = Waiter(json: tableJson["waiter"] as? [String:Any] ?? [:])
			table.waiter = waiter ?? Waiter() //<- This is important to assign a waiter, do not remove this line!
			
			var piOrderCode : String = ""
			
			if let customersBlock = tableJson["customers"] as? [[String : Any]] {
				if let customer = customersBlock.first {
					let discount = customer["restaurantDiscount"] as? Int ?? 0
					OrderManager.main.orders.discountInfo = discount
					let code = customer["piOrderCode"] as? String ?? ""
					piOrderCode = code
				}
			}
			
			// Fetch all orders that have been approved
			//	- mutates the OrderManager's current order
			OrderService.getOpenOrderForUser(resID: table.restaurantID, json: tableJson) { (success) in
				callback(table, piOrderCode)
			}
		}
	}

    static func tableServiceError(_ desc: String? = nil, code: Int = 0) -> NSError {
        let errorDescription = desc ?? "Could not get tableID. Check your internet connection and try again."
        return NSError(domain: "ca.zemind.rescounts", code: code, userInfo: ["localizedDescription": errorDescription])
    }
	//UNREVIEWED TAG
	static func getTotalForOrders(orders: [[String: Any]]) ->Int {
		var total = 0
		for order in orders {
			if let approved = order["approved"] as? Bool, approved {
				total += order["cost"] as? Int ?? 0
				total += order["taxAmount"] as? Int ?? 0
				total += order["tip"] as? Int ?? 0
			}
		}
		return total
	}
	static func getTipForOrders(orders:[[String: Any]]) -> Int {
		var total = 0
		for order in orders {
			if let approved = order["approved"] as? Bool, approved {
				total += order["tip"] as? Int ?? 0
			}
		}
		return total
	}
}
