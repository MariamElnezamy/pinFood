//
//  MessageService.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-11-28.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire


class MessageService: BaseService {
	typealias TargettedMessagesCallback = ([TargettedMessage]?) -> Void
	
	static func fetchMessages(location: CLLocationCoordinate2D, callback: @escaping TargettedMessagesCallback) {
		guard let url = urlWith(path:"messages/nearby") else {
			print ("MESSAGES ERROR: Invalid URL.")
			callback(nil)
			return
		}
		
		let args: [String: Any] =
			["latitude": location.latitude,
			 "longitude": location.longitude]
		
		Alamofire.request(url, parameters: args).responseJSON { response in
			printStatus("Messages", response.response?.statusCode)
			
			guard let json = response.result.value as? [String: Any] else {
				print ("MESSAGES ERROR: Invalid JSON.")
				callback(nil)
				return
			}
			
			var results: [TargettedMessage] = []
			if let messagesJson = json["messages"] as? [[String:Any]] {
				for messageInfo in messagesJson {
					if let message = TargettedMessage(json: messageInfo) {
						results.append(message)
						if results.count >= 15 {
							break
						}
					}
				}
			}
			
			callback(results)
		}
	}
}
