//
//  TargettedMessage.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-11-28.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import CoreLocation

class TargettedMessage: NSObject {
	
	public var messageID: String
	public var title: String
	public var message: String
	public var location: CLLocationCoordinate2D
	public var radius: Float
	
	
	// MARK: - Initialization
	
	init(id messageID: String, title: String, message: String, location: CLLocationCoordinate2D, radius: Float) {
		self.messageID = messageID
		self.title = title
		self.message = message
		self.location = location
		self.radius = radius
		
		super.init()
	}
	
	convenience init?(json: [String: Any]) {
		guard
			let messageID = json["id"] as? String,
			let message = json["description"] as? String,
			let latitude = (json[jsonDict: "location"]?["lat"] as? NSNumber)?.doubleValue,
			let longitude = (json[jsonDict: "location"]?["long"] as? NSNumber)?.doubleValue,
			let radius = (json["radius"] as? NSNumber)?.floatValue else
		{
			return nil
		}
		
		let title = json["title"] as? String ?? l10n("rescountsMessage")
		let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		
		
		if (!CLLocationCoordinate2DIsValid(location)) {
			return nil
		}
		
		self.init(id: messageID, title: title, message: message, location: location, radius: radius)
	}
	
	
	// MARK: - Public Methods
	
}
