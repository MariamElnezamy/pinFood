//
//  User.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-05.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import Stripe

class User: NSObject {
	
	typealias LoyaltyPointInfo = (points: Int, value: Int, currency: String)
	
	var userID: String
	var firstName: String
	var lastName: String
	var email: String
	var phoneNum: String = ""
	var birthday: Date?
	var promoCode : String?
	var rtyRes: String?
	var sharingCode: String?
	var profileImage: URL?
	var loyaltyPoints: Int = 0
    var reviewCount: Int = 0
	var reviews: [RestaurantReview] = []
	var stripeToken: STPToken?
	var card: Card?
	var firstOrderBonus: Bool = false
	var allTimeLoyaltyPointsCustomer: Int = 0
	var allTimeLoyaltyPointsWaiter: Int?
	var allTimeLoyaltyPointsReferral: Int = 0
	var loyaltyPointInfo: [LoyaltyPointInfo] = []
	var hasReferred: Bool = false
	var allowsOffer: Bool = false

	
	// MARK: - Initialization
	
	init(id userID: String, firstName: String, lastName: String, email: String, phoneNum: String ,birthday: Date? = nil, promoCode: String? = nil, rtyRes: String? = nil ,reviewCount: Int = 0, profileImage: URL? = nil, card : Card? = nil, allowsOffer: Bool = false) {
		self.userID = userID
		self.firstName = firstName
		self.lastName = lastName
		self.email = email
		self.birthday = birthday
		self.promoCode = promoCode
		self.rtyRes = rtyRes
		self.phoneNum = phoneNum
        self.reviewCount = reviewCount
		self.profileImage = profileImage
		self.card = card
		self.allowsOffer = allowsOffer
		
		super.init()
	}
	
	convenience init?(json: [String: Any]) {
		let userID: String = json["id"] as? String ?? ""
        let firstName: String = json["firstName"] as? String ?? ""
		let lastName: String = json["lastName"] as? String ?? ""
		let email: String = json["email"] as? String ?? ""
        let reviewCount: Int = (json["reviewCount"] as? Int) ?? 0
        let profileImage: URL? = URL(string: (json["profile"] as? String) ?? "")
		let phoneNum: String = json["phoneNumber"] as? String ?? ""
		let birthday: String = json["dateOfBirth"] as? String ?? ""
		let promoCode: String  = json["piCode"] as? String ?? ""
		let rtyRes: String = json["rtyRestaurantName"] as? String ?? ""
		
		
		if let paymentMethod = json["paymentMethod"] as? String{
			if paymentMethod == Constants.PaymentOption.apple {
				PaymentManager.main.applePayOption = true
			} else {
				PaymentManager.main.applePayOption = false
			}
		}
		
		var card: Card? = nil
		if let paymentSources = (json["paymentSources"] as? [[String: Any]] )?.first
		{ 	if let cardInfo = paymentSources["card"] as? [String : Any] {
				card = Card(json: cardInfo )
			}
		}
		
		self.init(id: userID, firstName: firstName, lastName: lastName, email: email, phoneNum: phoneNum, birthday: HoursManager.dateFromString(birthday) ?? nil, promoCode: promoCode, rtyRes: rtyRes, reviewCount: reviewCount, profileImage: profileImage, card: card)
		
		self.sharingCode = json["referralCode"] as? String
		
		// TODO: remove
//		let letters : NSString = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
//		let len = UInt32(letters.length)
//		var randomString = ""
//		for _ in 0 ..< 6 {
//			let rand = arc4random_uniform(len)
//			var nextChar = letters.character(at: Int(rand))
//			randomString += NSString(characters: &nextChar, length: 1) as String
//		}
//		self.sharingCode = randomString // TODO: remove
		
		self.firstOrderBonus = json["firstOrderBonus"] as? Bool ?? false
		self.allowsOffer = json["allowsPromotions"] as? Bool ?? false
		self.loyaltyPoints = (json["rewardPoints"] as? NSNumber)?.intValue ?? 0
//		self.loyaltyPoints = 1200 // TODO: remove
		self.allTimeLoyaltyPointsCustomer = (json["userRewardPointsTotal"] as? NSNumber)?.intValue ?? 0
		self.allTimeLoyaltyPointsWaiter = (json["waiterRewardPointsTotal"] as? NSNumber)?.intValue
		self.allTimeLoyaltyPointsReferral = (json["referralRewardPointsTotal"] as? NSNumber)?.intValue ?? 0
		
		if let referralUser = json["referralUser"] as? String, referralUser.count > 0 {
			self.hasReferred = true
		}
		
		if let rewardInfo = json["rewards"] as? [String: Any] {
			if let loyaltyInfo = rewardInfo["loyaltyPoints"] as? [String:Any] {
				let orderedKeys: [Int] = (loyaltyInfo.keys.map { Int($0) ?? 0 }).sorted()
				loyaltyPointInfo.removeAll()
				
				for key in orderedKeys {
					if let value = (loyaltyInfo[String(key)] as? NSNumber)?.intValue {
						loyaltyPointInfo.append((key,  value,  "CAD"))
					}
				}
			}
		}
		
		reviews.removeAll()
		(json["reviews"] as? [[String: Any]])?.forEach { (reviewDict) in
			if let review = RestaurantReview(json: reviewDict) {
				reviews.append(review)
			}
		}
	}
	
	
	// MARK: - Public Methods
	
	public static func testUser() -> User {
		Helper.assertTestBuild()
		
		let retVal = User(id: "123", firstName: "Bobson", lastName: "Dugnutt", email: "fake@email.com", phoneNum: "") // TODO: remove, just for testing
		retVal.loyaltyPoints = 47
		return retVal
	}
	
	public var loyaltyPointsProgress: CGFloat {
		if let nextTier = nextEligibleLoyaltyTier {
			return CGFloat(loyaltyPoints) / CGFloat(nextTier.points)
		} else {
			return 0
		}
	}
	
	public var hasEnoughLoyaltyPoints: Bool {
		return loyaltyPoints >= (topEligibleLoyaltyTier?.points ?? Int.max)
	}
	
	public var topEligibleLoyaltyTier: LoyaltyPointInfo? {
		for info in loyaltyPointInfo.reversed() {
			if info.points <= loyaltyPoints {
				return info
			}
		}
		return nil
	}
	
	public var nextEligibleLoyaltyTier: LoyaltyPointInfo? {
		for info in loyaltyPointInfo {
			if info.points > loyaltyPoints {
				return info
			}
		}
		return loyaltyPointInfo.last
	}
	
	public var isServer: Bool {
		return (self.allTimeLoyaltyPointsWaiter != nil) // TODO: make sure this value is missing from the JSON for non-servers. Otherwise find another value, or just check > 0.
	}

    public func dictionaryRepresentation() -> [String: Any] {
		var dictionary: [String: Any] = ["id": self.userID,
                                         "firstName": self.firstName,
                                         "lastName": self.lastName,
                                         "email": self.email,
										 "phoneNumber": self.phoneNum,
                                         "reviewCount": self.reviewCount,
										 "allowsPromotions": self.allowsOffer,
                                         "profile": self.profileImage?.absoluteString ?? ""]
		
		if self.birthday != nil, let realDate = self.birthday {
			dictionary["dateOfBirth"] = HoursManager.stringFromDate8601(realDate)
		}
		
		if self.promoCode != nil, let code = self.promoCode {
			dictionary["piCode"] = code
		}
		
		if self.rtyRes != nil, let res = self.rtyRes {
			dictionary["rtyRestaurantName"] = res
		}

        return dictionary
    }
	
	// MARK: - Private Helpers
}
