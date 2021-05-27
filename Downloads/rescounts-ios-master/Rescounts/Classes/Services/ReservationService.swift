//
//  ReservationService.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-08-22.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import Alamofire


class ReservationService: BaseService {
	typealias ReservationCallback = (RestaurantTable?, ReservationError) -> Void
	
	static func claimTable(restaurant: Restaurant, numPeople: Int, isRDeals: Bool, reservationTime: Date, special: String?, callback: @escaping ReservationCallback) {
		guard restaurant.restaurantID.count > 0, let url = urlWith(path:"restaurants/\(restaurant.restaurantID)/tables") else {
			completedWith(table: nil, restaurant: nil, callback: callback, errorMessage: "Invalid URL for restaurantID: \(restaurant.restaurantID)", errorEnum: ReservationError.genericError)
			return
		}
		
		let numberSeats = (numPeople == 0 ? 1 : numPeople)
		
		var args : [String: Any] = ["seatingAt" : HoursManager.stringFromDate8601(reservationTime),
									"numberOfSeats" : numberSeats ,
									"seatingRequest" : special ?? ""]
		if (numPeople == 0 ) {
			args["pickup"] = true
		}
		if (isRDeals) {
			args["rdeal"] = true
		}
		
		Alamofire.request(url, method:.post, parameters: args, encoding: JSONEncoding.default, headers:["Authorization": AccountManager.main.tokenArg]).responseJSON { response in
			printStatus("Reservation", response.response?.statusCode)
			
			handleResult(response: response, restaurant: restaurant, isPickup: (numPeople == 0), callback: callback)
		}
	}
	
	static func rescheduleTable(tableID: String, restaurant: Restaurant, numPeople: Int, reservationTime: Date, special: String?, callback: @escaping ReservationCallback) {
		
		guard tableID.count > 0, let url = urlWith(path:"tables/\(tableID)") else {
			completedWith(table: nil, restaurant: nil, callback: callback, errorMessage: "Invalid URL for tableID: \(tableID)", errorEnum: ReservationError.genericError)
			return
		}
		
		
		let numberSeats = (numPeople == 0 ? 1 : numPeople)
		
		var args : [String : Any] = ["seatingAt": HoursManager.stringFromDate8601(reservationTime),
									 "numberOfSeats": numberSeats ,
									 "seatingRequest" : special ?? ""]
		
		if (numPeople == 0 ) {
			args["pickup"] = true
		}
		
		Alamofire.request(url, method:.post, parameters: args, encoding: JSONEncoding.default, headers:["Authorization": AccountManager.main.tokenArg]).responseJSON { response in
			printStatus("Reservation", response.response?.statusCode)
			
			handleResult(response: response, restaurant: restaurant, isPickup: (numPeople == 0), callback: callback)
		}
	}
    
    
    static func updateRdeals(isRDeals: Bool, callback: @escaping (Bool?, NSError?, String?) -> Void) {
        
        guard let url = urlWith(path:"tables/\(OrderManager.main.currentTable?.tableID ?? "")/rdeals") else {
            callback(false, nil , "Invalid URL for updateRdeals:     ")
            return
        }
        
        var args : [String: Any] = [:]
        if (isRDeals) {
            args["rdeals"] = isRDeals
        }
        
        Alamofire.request(url, method:.put, parameters: args, encoding: JSONEncoding.default, headers:["Authorization": AccountManager.main.tokenArg]).responseJSON { response in
            printStatus("JupdateRdeals", response.response?.statusCode)
            
            callback(true,nil,nil)
        }
    }
	
	static func joinTable(restaurant: Restaurant, code: String, isRDeals: Bool, callback: @escaping ReservationCallback) {
		
		guard restaurant.restaurantID.count > 0, code.count > 0, let url = urlWith(path:"restaurants/\(restaurant.restaurantID)/tables/\(code)/join") else {
			completedWith(table: nil, restaurant: nil, callback: callback, errorMessage: "Invalid URL for restaurantID: \(restaurant.restaurantID)", errorEnum: ReservationError.genericError)
			return
		}
		
		var args : [String: Any] = [:]
		if (isRDeals) {
			args["rdeals"] = true
		}
		
		Alamofire.request(url, method:.post, parameters: args, encoding: JSONEncoding.default, headers:["Authorization": AccountManager.main.tokenArg]).responseJSON { response in
			printStatus("Join Table", response.response?.statusCode)
			
			handleResult(response: response, restaurant: restaurant, isJoining: true, callback: callback)
		}
	}
	
	static func cancelTable(tableID: String, callback: @escaping RescountsServiceCallback) {
		
		guard tableID.count > 0, let url = urlWith(path:"tables/\(tableID)") else {
			callback(false)
			return
		}
		
		Alamofire.request(url, method:.delete, encoding: JSONEncoding.default, headers:["Authorization": AccountManager.main.tokenArg]).responseJSON { response in
			printStatus("Delete Reservation", response.response?.statusCode)
			
			if let statusCode = response.response?.statusCode {
				
				let success = (200 ... 299 ~= statusCode) || (404 == statusCode) // 404 means that table no longer exists, so it's as good as cancelled
				if success {
					OrderManager.main.clearTable()
				}
				callback(success)
			}
		}
	}
	
	static func cancelPickUp(tableID: String, callback: @escaping RescountsServiceCallback) {
		guard tableID.count > 0 , let url = urlWith(path: "tables/\(tableID)/cancel") else {
			callback(false)
			return
		}
		
		Alamofire.request(url, method:.post, encoding: JSONEncoding.default, headers: ["Authorization": AccountManager.main.tokenArg]).responseJSON { response in
			printStatus("Delete Pickup Reservation", response.response?.statusCode)
			
			if let statusCode = response.response?.statusCode{
				let success = (200 ... 299 ~= statusCode) || (404 == statusCode) // 404 means that table no longer exists, so it's as good as cancelled
				if success {
					OrderManager.main.clearTable()
				}
				callback(success)
			}
		}
	}
    
    static func autoDeclineTable(tableID: String, callback: @escaping RescountsServiceCallback) {
        
        guard tableID.count > 0, let url = urlWith(path:"tables/\(tableID)/autodecline") else {
            callback(false)
            return
        }
        
        Alamofire.request(url, method:.post, encoding: JSONEncoding.default, headers:["Authorization": AccountManager.main.tokenArg]).responseJSON { response in
            printStatus("Delete Reservation", response.response?.statusCode)
            
            if let statusCode = response.response?.statusCode {
                
                let success = (200 ... 299 ~= statusCode)
                if success {
                    OrderManager.main.clearTable()
                }
                callback(success)
            }
        }
    }
	
	private static func handleResult(response: DataResponse<Any>, restaurant: Restaurant, isPickup: Bool = false, isJoining: Bool = false, callback: @escaping ReservationCallback) {
		guard let json = response.result.value as? [String: Any] else {
			completedWith(table:nil, restaurant: nil, callback: callback, errorMessage:"Invalid JSON.", errorEnum: ReservationError.genericError)
			return
		}

		if let table = RestaurantTable(json: json, name: restaurant.name) {
			completedWith(table: table, restaurant: restaurant, callback: callback, isPickup: isPickup, isJoining: isJoining, errorEnum: .noError)
		} else if let error = json["error"] as? String, error=="no token stored" {
			completedWith(table:nil, restaurant: nil, callback: callback, isPickup: isPickup, isJoining: isJoining, errorMessage:l10n("missingPaymentDetails"), errorEnum: .noToken)
		} else if response.response?.statusCode == 404 {
			completedWith(table:nil, restaurant: nil, callback: callback, isPickup: isPickup, isJoining: isJoining, errorMessage:l10n("couldNotReachServer"), errorEnum: .noTable)
		} else if response.response?.statusCode == 409 {
			completedWith(table:nil, restaurant: nil, callback: callback, isPickup: isPickup, isJoining: isJoining, errorMessage:l10n("accountNotActivated"), errorEnum: .notActivated)
		} else {
			completedWith(table:nil, restaurant: nil, callback: callback, isPickup: isPickup, isJoining: isJoining, errorMessage:l10n("couldNotReachServer"), errorEnum: .genericError)
		}
	}
	
	private static func completedWith(table: RestaurantTable?, restaurant: Restaurant?, callback: @escaping ReservationCallback, isPickup: Bool = false, isJoining: Bool = false, errorMessage: String? = nil, errorEnum:ReservationError) {
		if let errorMessage = errorMessage {
			print ("RESERVATION ERROR: \(errorMessage)")
		}
		if let table = table, let restaurant = restaurant {
			OrderManager.main.startNewTable(table, restaurant: restaurant, isJoining: isJoining, isPickup: isPickup)
		}
		
		callback(table, errorEnum)
	}
	
	public enum ReservationError {
		case noError
		case genericError
		case noToken
		case noTable
		case notActivated
	}
}
