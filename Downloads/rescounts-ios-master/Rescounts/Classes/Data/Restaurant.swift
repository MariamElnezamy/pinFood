//
//  Restaurant.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-15.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import CoreLocation

class Restaurant: NSObject {
	var restaurantID: String
	var name: String
	var address: String = ""
	var location: CLLocationCoordinate2D
	var currencySymbol: String = "$"
	var averagePrice: Int = 0
	var taxRate: Float = 0.13
	var defaultTip: Float = Constants.User.defaultTip
	var rating: Float = 0.0
	var serverRating: Float = 0.0
	var numRatings: Int = 0
	var restaurantDescription: String = ""
	var eventsAndEntertainment : String = ""
	var holidayHours : String = ""
	var website : String = ""
	var cuisineTypes: [String] = []
	var thumbnailURL: URL?
	var restaurantPhotos: [URL] = []
	var userPhotos: [URL] = []
	var isOnline: Bool = false
	var hours: WeeklyHours?
	var reviews: [RestaurantReview] = []
	var rDealsInfo: RDealsInfo? = nil
	
	
	init(id restaurantID: String, name: String, location: CLLocationCoordinate2D) {
		self.restaurantID = restaurantID
		self.name = name
		self.location = location
		
		super.init()
	}
	
	convenience init?(json: [String: Any]) {
		if let resID = json["id"] as? String, let name = json["name"] as? String {
			self.init(id: resID,
					  name: name,
					  location: CLLocationCoordinate2D(latitude: json[jsonDict:"location"]?["lat"]  as? Double ?? 0.0,
													   longitude:json[jsonDict:"location"]?["long"] as? Double ?? 0.0))
			
			if let thumbnailStr = json["thumbnail"] as? String, let newThumbnailURL = URL(string: thumbnailStr) {
				thumbnailURL = newThumbnailURL
			} else {
				thumbnailURL = nil
			}
			address = json["address"] as? String ?? ""
			restaurantDescription = json["description"] as? String ?? ""
			eventsAndEntertainment = json["eventsAndEntertainment"] as? String ?? ""
			holidayHours = json["holidayHours"] as? String ?? ""
			website = json["website"] as? String ?? ""
			rating = (json["rating"] as? NSNumber)?.floatValue ?? 0.0
			serverRating = (json["serverRating"] as? NSNumber)?.floatValue ?? 0.0
			currencySymbol = json["currency_symbol"] as? String ?? "$"
			averagePrice = (json["averageCost"] as? NSNumber)?.intValue ?? 0
			numRatings = (json["reviewCount"] as? NSNumber)?.intValue ?? 0
			
			if let flatTaxRate = (json["flatTaxRate"] as? NSNumber)?.floatValue {
				taxRate = flatTaxRate
			} else if json["taxCode"] as? String == Constants.TaxCode.ontario {
				taxRate = 0.13
			}
			defaultTip = (json["defaultTip"] as? NSNumber)?.floatValue ?? Constants.User.defaultTip
			
			cuisineTypes.removeAll()
			(json["foodTypes"] as? [[String: Any]])?.forEach { (foodType) in
				if let foodTypeID = foodType["id"] as? Int, let foodTypeName = (CuisineType(rawValue: foodTypeID)?.localizedDisplay ?? foodType["en"]) as? String {
					cuisineTypes.append(foodTypeName)
				}
			}
			
			restaurantPhotos.removeAll(keepingCapacity: true)
			(json["images"] as? [String])?.forEach {
				if let url = URL(string: $0) {
					restaurantPhotos.append(url)
				}
			}
			
			userPhotos.removeAll(keepingCapacity: true)
			(json["userImages"] as? [String])?.forEach {
				if let url = URL(string: $0) {
					userPhotos.append(url)
				}
			}
			
			reviews.removeAll(keepingCapacity: true)
			(json["reviews"] as? [[String:Any]])?.forEach {
				if let review = RestaurantReview(json: $0, fromRestaurant: name) {
					review.replyName = name
					reviews.append(review)
				}
			}
			
			isOnline = (json["is_online"] as? NSNumber)?.boolValue ?? false // TODO: fix, not present in JSON
			
			if let hoursJson = json["hours"] as? [[String:Any]] {
				hours = WeeklyHours(json: hoursJson)
			}
			
			rDealsInfo = RDealsInfo(json: json)
			// TODO: remove this temp code -- the API was missing RDealsInfo from the individual restaurant endpoint (which we use to resume an order)
			if let rDealsInfo = rDealsInfo, let curRest = OrderManager.main.currentRestaurant, curRest.restaurantID == restaurantID, curRest.rDealsInfo == nil {
				curRest.rDealsInfo = rDealsInfo
			}
			
			if let rDealsInfo = rDealsInfo, rDealsInfo.fee > 0 {
				OrderManager.main.lastKnownRDealsFee = rDealsInfo.fee
			}
			
		} else {
			return nil
		}
	}
	
	
	// MARK: Public Getters
	
	public func cuisineTypesAsString() -> String {
		return cuisineTypes.joined(separator: ", ")
	}
	
	public func averagePriceAsString(short : Bool = false) -> String? {
		let formattedPrice : String = CurrencyManager.main.getCost(cost: averagePrice, hideDecimals: true)
		let theString = String.localizedStringWithFormat(l10n("avgPrice"), formattedPrice)
		if (short) {
			return (averagePrice > 0) ? "\(formattedPrice) / -" : nil
		}
		return (averagePrice > 0) ? theString : nil
	}
	
	public func isOpen() -> Bool {
		if let todaysHours = hours?.todaysHours(),
		   let open  = HoursManager.dateFromHoursString(todaysHours.open),
		   let close = HoursManager.dateFromHoursString(todaysHours.close)
		{
			let adjustedClose = (close > open) ? close : Date(timeInterval: 60*60*24, since: close) // Add a day to the close time if it crosses midnight
			return Date().isBetween(open, adjustedClose)
		} else {
			return isOnline
		}
	}
	
	public func todaysHoursAsString() -> String {
		return hours?.todaysHoursAsString() ?? ""
	}
	
	override func isEqual(_ object: Any?) -> Bool {
		return restaurantID == ((object as? Restaurant)?.restaurantID ?? "non_existent_id")
	}
}
