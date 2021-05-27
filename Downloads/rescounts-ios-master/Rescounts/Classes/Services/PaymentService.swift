//
//  PaymentService.swift
//  Rescounts
//
//  Created by Kittiphong Xayasane on 2018-08-28.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import Alamofire

class PaymentService: BaseService {
	typealias paymentCallback = (String?, NSError?, Int?, Int?, Float?, Int?, Bool?, Float?) -> Void
	
	static func payBill(tableID: String, tip: Int, redeemPoints: Int = 0, callback: @escaping paymentCallback) {
		guard tableID.count > 0, let url = urlWith(path: "tables/\(tableID)/close") else {
			print ("Payment error: invalid JSON.")
			callback(nil, nil, nil, nil, nil, nil, nil, nil)
			return
		}
		
		guard let restaurant = OrderManager.main.currentRestaurant, let table = OrderManager.main.currentTable else {
			print ("Can't checkout, no current restaurant or table.")
			callback(nil, nil, nil, nil, nil, nil, nil, nil)
			return
		}
		
        let paymentModel: [String: Any] = ["tip": tip, "redeemPoints": redeemPoints]
		
		let headers: HTTPHeaders = [
			"Content-Type" : "application/json",
			"Authorization" : AccountManager.main.tokenArg
		]
		
		let defaultTip: Float = table.shouldApplyTip ? restaurant.defaultTip : 0
		
		Alamofire.request(url, method: .post, parameters: paymentModel, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
			guard let httpResponse = response.response else {
				print ("ERROR PAYING A BILL: Could not reach server.")
				callback(nil, payBillError(l10n("couldNotReachServer")), nil, nil, nil, nil, nil, nil)
				return
			}
			printStatus("PAY THE BILL", httpResponse.statusCode)
			
			guard let json = response.result.value as? [String: Any] else {
				print ("ERROR PAYING BILL RESPONSE: Invalid JSON.")
				callback(nil, payBillError(), nil, nil, nil,nil, nil, nil)
				return
			}
			
			if 200 ... 299 ~= httpResponse.statusCode {
				printStatus("PAY BILL SUCCEEDED: ", httpResponse.statusCode)
				guard let earnedPoints = json["earnedPoints"] as? Int else {
					callback("Good", nil, nil, nil, nil,nil, nil, nil)
					return
				}
				guard let bonusPoints = json["bonusPoints"] as? Int else {
					callback("Good", nil, earnedPoints, nil, nil,nil, nil, nil)
					return
				}
				
				guard let reducedTip = json["reducedTip"] as? Int else {
					callback("Good", nil, earnedPoints, bonusPoints, nil,nil, nil, nil)
					return
				}
				var firstOrder = false
				
				if let first = json["firstOrder"] as? Bool {
					firstOrder = first
				}
				
				var multiplier : Float = 0.0
				
				if let rtyMultiplier = json["rtyRewardMultiplier"] as? Float {
					multiplier = rtyMultiplier
				}
				
				callback("Good", nil, earnedPoints, bonusPoints, defaultTip, reducedTip, firstOrder, multiplier)
				
				UserDefaults.standard.set(true, forKey: Constants.UserDefaults.hasFinishedAnOrder)
				UserDefaults.standard.synchronize()
			} else {
				callback(nil, payBillError(), nil, nil, nil,nil, nil, nil)
				return
			}
			
		}
		
		func payBillError(_ desc: String? = nil, code: Int = 0) -> NSError {
			let errorDescription = desc ?? l10n("payBillGeneric")
			return NSError(domain: "ca.zemind.rescounts", code: code, userInfo: ["localizedDescription": errorDescription])
		}
		
	}
}
