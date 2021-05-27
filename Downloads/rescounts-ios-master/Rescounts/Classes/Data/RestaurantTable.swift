//
//  RestaurantTable.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-08-22.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class RestaurantTable: NSObject {
	
	public let tableID: String
	public let restaurantID: String
	public var restaurantName: String
	public let numberOfSeats: Int
	public var seatingAt: Date = Date()
	public var approved: Bool = false
	public var approvedAt: Date?
	public var waiter : Waiter? //TODO: Add when we know what the waiter model looks like
	public var piOrderNum: String = ""
	public var joinCode: String = ""
	public var pickup: Bool = false
	public var isRDeals: Bool = false
//	public var orders: [Order] = []
	
	init(id tableID: String, restaurantID: String, restaurantName: String, numberOfSeats: Int, seatingAt: Date, pickup: Bool, isRDeals: Bool) {
		self.tableID = tableID
		self.restaurantID = restaurantID
		self.restaurantName = restaurantName
		if pickup {
			self.numberOfSeats = 0
		} else {
			self.numberOfSeats = numberOfSeats
		}

		self.isRDeals = isRDeals
		self.seatingAt = seatingAt
		self.pickup = pickup
		super.init()
	}
	
	convenience init?(json: [String: Any], name: String = "") {
		if let tableID = json["id"] as? String,
			let restaurantID = json["restaurantID"] as? String,
			var numberOfSeats = json["numberOfSeats"] as? Int,
			let seatingAt = HoursManager.dateFromString(json["seatingAt"] as? String)
		{
			let customer = (json["customers"] as? [[String : Any]])?.first
			let rDeals = json["rdeal"] as? Bool ?? customer?["rdeal"] as? Bool ?? false
			let pick = json["pickup"] as? Bool ?? false
			if (pick) {
				numberOfSeats = 0
			}
			
			self.init(id: tableID, restaurantID: restaurantID, restaurantName: name, numberOfSeats: numberOfSeats, seatingAt: seatingAt, pickup: pick, isRDeals: rDeals)
			
			approved = (json["approved"] as? NSNumber)?.boolValue ?? false
			piOrderNum = json["piOrderCode"] as? String ?? ""
			joinCode = json["shortID"] as? String ?? ""
		} else {
			return nil
		}
	}
	
	public func assignWaiter(waiter: Waiter) {
		self.waiter = waiter
	}
	
	public var reservationDetails: String {
		var numSeats = ""
		if pickup {
			numSeats = l10n("pickup")
		} else {
			numSeats = "\(numberOfSeats) \(numberOfSeats == 1 ? "Person" : "People")"
		}
		return "\(HoursManager.userFriendlyDate(seatingAt)) - \(numSeats)"
	}
	
	public var shouldApplyTip: Bool {
		return numberOfSeats >= 6
	}
}
