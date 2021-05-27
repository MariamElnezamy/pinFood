//
//  Waiter.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-09-12.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation

class Waiter : NSObject {
	var firstName : String
	var lastName : String
	var profile: URL?
	var reviewCount: Int = 0
	
	init(firstName: String = "", lastName: String = "", reviewCount: Int = 0, profile:URL? = nil) {
		self.firstName = firstName
		self.lastName = lastName
		self.reviewCount = reviewCount
		self.profile = profile
		super.init()
	}
	
	convenience init?(json: [String: Any]) {
		let firstName : String = json["firstName"] as? String ?? ""
		let lastName : String = json["lastName"] as? String ?? ""
		let reviews : Int = json["reviewCount"] as? Int ?? 0
		let profile : URL? = URL(string: (json["profile"] as? String) ?? "")
		self.init(firstName : firstName, lastName: lastName, reviewCount: reviews, profile: profile)
	}
	
	
}
