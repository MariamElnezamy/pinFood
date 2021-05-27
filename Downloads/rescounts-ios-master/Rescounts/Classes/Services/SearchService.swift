//
//  SearchService.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-15.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class SearchService: BaseService {
	
	typealias RestaurantCallback = (Restaurant?) -> Void
	typealias SearchCallback = ([Restaurant]?, Bool) -> Void
	
	private static var sCallCount: Int = 0
	
	
	static func isSearchCallActive() -> Bool {
		return (sCallCount > 0)
	}
	
	static func fetchRestaurants(location: CLLocationCoordinate2D, offset: Int = 0, includeClosed: Bool = true, rDeals: Bool = false, callback: @escaping SearchCallback) {
		
		guard let url = urlWith(path:"restaurants/nearby") else {
			print ("SEARCH ERROR: Invalid URL.")
			callback(nil, rDeals)
			return
		}
		
        let args: [String: Any] =
			["latitude": location.latitude,
			 "longitude": location.longitude,
			 "limit": 25,
			 "offset": offset,
			 "filter" : !includeClosed]
		
		var headers: HTTPHeaders = [:]
		
		if let code = AccountManager.main.user?.promoCode, code != "" {
			headers = ["Authorization": AccountManager.main.tokenArg]
		}
		
		AccountManager.main.cleanCache(url)
		
		sCallCount += 1
		Alamofire.request(url, parameters: args, headers: headers).responseJSON { response in
			sCallCount -= 1
			printStatus("Search", response.response?.statusCode)
			
			guard let json = response.result.value as? [String: Any] else {
				print ("SEARCH ERROR: Invalid JSON.")
				callback(nil, rDeals)
				return
			}
			
			var results: [Restaurant] = []
			(json["restaurants"] as? [[String:Any]])?.forEach {
				if let restaurant = Restaurant(json: $0), (includeClosed || restaurant.isOpen()) {
					results.append(restaurant)
				}
			}
			
			saveSearchLocation(location)
			callback(results, rDeals)
		}
	}
	
	static func fetchRestaurants(location: CLLocationCoordinate2D, searchString: String, rDeals: Bool = false, callback: @escaping SearchCallback) {
		guard let url = urlWith(path:"restaurants/search") else {
			print ("SEARCH ERROR: Invalid URL.")
			callback(nil, rDeals)
			return
		}
		
        let args: [String: Any] =
			["latitude": location.latitude,
			 "longitude": location.longitude,
			 "query": searchString]
        
		var headers: HTTPHeaders = [:]
		
		if let code = AccountManager.main.user?.promoCode, code != "" {
			headers = ["Authorization": AccountManager.main.tokenArg]
		}
		
		AccountManager.main.cleanCache(url)
		
		sCallCount += 1
		Alamofire.request(url, parameters: args, headers: headers).responseJSON { response in
			sCallCount -= 1
			printStatus("Search", response.response?.statusCode)
			
			guard let json = response.result.value as? [String: Any] else {
				print ("SEARCH ERROR: Invalid JSON.")
				callback(nil, rDeals)
				return
			}
			
			var results: [Restaurant] = []
			var showOnceGoogleReminder: Bool = true
			if let restaurantsJson = json["restaurants"] as? [[String:Any]] {
				for restaurantInfo in restaurantsJson {
					if let restaurant = Restaurant(json: restaurantInfo) {
						results.append(restaurant)
						/*
						if results.count >= 15 {
							break
						}*/
					}
					
					if let fromGoogle = restaurantInfo["fromGoogle"] as? Bool {
						if showOnceGoogleReminder && fromGoogle {
							RescountsAlert.showAlert(title:"", text: l10n("fromGoogle"))
							showOnceGoogleReminder = false
						}
					}
				}
			}
			
			saveSearchLocation(location)
			callback(results, rDeals)
		}
	}
	
	static func fetchRestaurant(restaurantID: String, callback: @escaping RestaurantCallback) {
		guard restaurantID.count > 0, let url = urlWith(path:"restaurants/\(restaurantID)") else {
			print ("SEARCH ERROR: Invalid URL.")
			callback(nil)
			return
		}
		
		var headers: HTTPHeaders = [:]
		
		if let code = AccountManager.main.user?.promoCode, code != "" {
			headers = ["Authorization": AccountManager.main.tokenArg]
		}
		
		Alamofire.request(url, headers: headers).responseJSON { response in
			printStatus("Search", response.response?.statusCode)
			
			guard let json = response.result.value as? [String: Any] else {
				print ("SEARCH ERROR: Invalid JSON.")
				callback(nil)
				return
			}
			
			callback(Restaurant(json: json))
		}
	}
	
	static private func saveSearchLocation(_ location: CLLocationCoordinate2D) {
		//Save the current LocationMananager.lastKnownLocation to user defaults as "lastSearchLocation"
		UserDefaults.standard.set(["lat": LocationManager.currentLocation().latitude, "long": LocationManager.currentLocation().longitude], forKey: Constants.UserDefaults.lastSearchLocation )
		UserDefaults.standard.synchronize()
	}
}
