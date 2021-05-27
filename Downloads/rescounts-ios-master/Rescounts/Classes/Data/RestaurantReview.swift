//
//  RestaurantReview.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-31.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class RestaurantReview: NSObject {
	var reviewID: String
//	var userID: Int
	var userFirstName: String = ""
	var userLastName: String = ""
	var userReviewCount: Int = 1
	var userPhotoURL: URL?
	var timestamp: Date
	var lastEdited: Date?
	var rating: Float = 0.0
	var serverRating: Float = 0.0
	var reviewText: String = ""
	var replyName: String?
	var replyText: String?
	
	
	// MARK: - Initialization
	
	init(id reviewID: String, /*userID: Int, */ timestamp: Date) {
		self.reviewID = reviewID
//		self.userID = userID
		self.timestamp = timestamp
		
		super.init()
	}
	
	convenience init?(json: [String: Any], fromRestaurant: String? = nil) {
		if let revID = json["id"] as? String, /*let uID = json["user_id"] as? Int, */ let date = HoursManager.dateFromString(json["timestamp"] as? String) {
			self.init(id: revID, /*userID: uID,*/ timestamp: date)
			
			if let user = json["user"] as? [String:Any] {
				userFirstName = user["firstName"] as? String ?? ""
				userLastName = user["lastName"] as? String ?? ""
				userReviewCount = (user["reviewCount"] as? NSNumber)?.intValue ?? 0
				if let photoUrlStr = user["profile"] as? String, let newPhotoURL = URL(string: photoUrlStr) {
					userPhotoURL = newPhotoURL
				}
			}
			
			reviewText = json["text"] as? String ?? ""
			rating = (json["rating"] as? NSNumber)?.floatValue ?? 0.0
			serverRating = (json["serverRating"] as? NSNumber)?.floatValue ?? 0.0
			replyText = json["reply"] as? String ?? ""
			replyName = json["restaurantName"] as? String ?? fromRestaurant
			lastEdited = HoursManager.dateFromString(json["lastEdited"] as? String)
			
		} else {
			return nil
		}
	}
	
	
	// MARK: - Public Methods
	
	public var userDisplayName: String {
		var lastName = userLastName.count > 0 ? String(userLastName.prefix(1)) : ""
		if lastName.count > 0 {
			lastName = " \(lastName)."
		}
		return "\(userFirstName)\(lastName)"
	}
	
	public func timestampAsString() -> String {
		return HoursManager.stringFromDate(timestamp)
	}
	
	public func lastEditedAsString() -> String {
		if let lastEdited = lastEdited {
			return HoursManager.stringFromDate(lastEdited)
		} else {
			return ""
		}
	}
	
	public func reviewCountAsString() -> String {
		return String.localizedStringWithFormat(userReviewCount == 1 ? l10n("numReviews.one") : l10n("numReviews.other"), userReviewCount)
	}
	
	public func hasReply() -> Bool {
		return (replyText?.count ?? 0) > 0
	}
}
