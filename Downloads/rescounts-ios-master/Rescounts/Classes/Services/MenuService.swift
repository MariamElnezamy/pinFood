//
//  MenuService.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-09.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import Alamofire

class MenuService: BaseService {
	
	typealias MenuCallback = (Menu?) -> Void
	
	static func fetchMenu(restaurantID: String, retryCount: Int = 0, callback: @escaping MenuCallback) {
		if useTestData() {
			fetchFakeMenu(callback: callback)
			return
		}
		
		guard restaurantID.count > 0, let url = urlWith(path:"restaurants/\(restaurantID)/menus") else {
			print ("MENU ERROR: Invalid URL for restaurantID: \(restaurantID)")
			callback(nil)
			return
		}
		
		//let manager = Alamofire.SessionManager.default
		//manager.session.configuration.timeoutIntervalForRequest = 8 // a way of setting timeout interval 8
		//reference https://rudybermudez.io/handing-network-problems-gracefully-with-alamofire
		
		Alamofire.request(url).responseJSON { response in
			printStatus("Menu", response.response?.statusCode)
			
			guard let json = response.result.value as? [String: Any], 200 ... 299 ~= response.response?.statusCode ?? 999 else {
				print ("MENU ERROR: Invalid JSON.")
				if (retryCount < 2) {
					fetchMenu(restaurantID: restaurantID, retryCount: retryCount+1, callback: callback)
				} else {
					callback(nil)
				}
				return
			}
			
			var menu: Menu? = nil
			if let menuDict = (json["menus"] as? [[String: Any]])?.first {
				menu = Menu(json: menuDict)
			}
			
			callback(menu)
		}
	}
	
	static func fetchFakeMenu(callback: @escaping MenuCallback) {
		
		guard let jsonStr = try? String(contentsOfFile: Bundle.main.path(forResource: "test_menu", ofType: "json") ?? "") else {
			print ("MENU ERROR: Couldn't find file.")
			callback(nil)
			return
		}
		
		let jsonData = jsonStr.data(using: String.Encoding.utf8) ?? Data()
		
		guard let json = try? JSONSerialization.jsonObject(with: jsonData, options: []) as! [String:Any] else {
			print ("MENU ERROR: Invalid JSON.")
			callback(nil)
			return
		}
		
		let menu = Menu(json: json)
		
		callback(menu)
	}
}
