//
//  Constants.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-18.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import CoreLocation

struct Constants {
	struct UserDefaults {
		static let userLocation = "RescountsUserLocation"
		static let lastSearchLocation = "lastSearchLocation"
        static let userDetails = "UserDetails"
        static let userAuthToken = "UserAuthToken"
		static let lastUsedEmail = "LastUsedEmail"
		static let firstInstalledVersion = "firstInstalledVersion"
		static let firstInstalledDate = "firstInstalledDate"
		static let hasFinishedAnOrder = "hasFinishedAnOrder"
		static let disabledNotifications = "disabledNotifications"
		static let referralPoints = "allTimeReferralPoints"
		static let shownMessageIDs = "shownMessageIDs"
		static let isTimerRunning = "isTimerRunning"
		static let onlyShowAvailable = "onlyShowAvailable"
		static let playedTutVideo = "playTutVideo"
		static let autoCancelTimerRunning = "autoCancelTimerRunning"
		static let autoCancelTime = "autoCancelTime"
	}
	struct User {
		static let defaultTip: Float = 0.15
	}
	struct Location {
		static let identifier = Locale.current.identifier
		static let toronto = CLLocationCoordinate2D(latitude: 43.651790, longitude: -79.382484)
	}
	struct Menu {
		static let rDealsName: String = "RDeals"
		static let padding: CGFloat = 20
		static let paddingTop: CGFloat = 15
		static let spacer: CGFloat = 10
		static let priceWidth: CGFloat = 65
		static let priceSpacer: CGFloat = 5
		static let thumbnailHeight: CGFloat = 74
		static let priceHeight: CGFloat = 18
		static let separatorHeight: CGFloat = 1
		static let sectionHeaderHeight: CGFloat = 45
	}
	struct Order {
		static let signUpBonusBoundary: Int = 999
		static let cellPaddingTop: CGFloat = 20
		static let spacer: CGFloat = 4
		static let textHeight: CGFloat = 18
		static let detailFontSize: CGFloat = 14
		static let leftMargin: CGFloat = 25
		static let bottomMargin: CGFloat = 40
		static let optionTopMargin: CGFloat = 15
		static let disclaimerHeight: CGFloat = 150
		static let reducedSpace : CGFloat = 10
		static let thumbnailHeight : CGFloat = 160
	}
	struct Review {
		static let paddingTop: CGFloat = 15
		static let paddingSide: CGFloat = 20
		static let spacer: CGFloat = 12
		static let photoSize: CGFloat = 50
		static let lineHeight: CGFloat = 20
		static let separatorHeight: CGFloat = 1
	}
	struct Restaurant {
		static let maxRating = 5
		static let lineHeight: CGFloat = 20
	}
	struct Profile {
		static let separatorHeight: CGFloat = 1
		static let imageHeight: CGFloat = 85
		static let profilePhotoPaddingTop: CGFloat = 20
		static let imageCornerRadius: CGFloat = 14
		static let imageBorderWidth: CGFloat = 2
		static let notificationRowID = "notificationRow"
		static let cities = [
			"Ajax",
			"Aurora",
			"Brampton",
			"Burlington",
			"Cambridge",
			"Etobicoke",
			"Guelph",
			"Hamilton",
			"Kitchener",
			"London",
			"Markham",
			"Milton",
			"Mississauga",
			"Newmarket",
			"North York",
			"Oakville",
			"Oshawa",
			"Pickering",
			"Richmond Hill",
			"Scarborough",
			"Toronto",
			"Vaughan",
			"Waterloo",
			"Whitby",
			"Other"
		]
	}
	struct Stripe {
                static var stripePublishableKey = "pk_test_kIDozUrRDueAQd7fl36alfGT"
        //        static var stripePublishableKey = "pk_live_i6YbUBsgBHnR65vi2JXzelFj"
        //        static let backendBaseURL: String? = "https://api.rescounts.com/api/v1"
                static let backendBaseURL: String? = "http://192.168.0.4:8088/api/v1"
                static let appleMerchantID: String? = "merchant.com.rescounts.iosapp"
	}
	struct TaxCode {
		static let ontario = "OntarioHST"
	}
	struct App {
		static let appID = "1437921394"
		static let rateURLString = "itms-apps://itunes.apple.com/app/id\(appID)"
	}
	struct Debug {
		static let useTestData: Bool = false
	}
	struct PaymentOption {
		static let credit = "CreditCard"
		static let apple = "ApplePay"
		static let cleanUpToken = "DELETE_ALL_TOKENS"
	}
	struct Notification {
		static let categoryA = "NotificationManagerCategory"
		static let first4Or5Rate =  "first4Or5Rate"
	}
	struct Rescounts {
		static let supportNumber = "18333366343"
		static let supportNumberDisplay = "1-833-336-6343"
	}
	
	// Used as keys, should not be used directly for display
	public enum DayOfWeek : String {
		case Mon   = "Mon"
		case Tues  = "Tues"
		case Wed   = "Wed"
		case Thurs = "Thurs"
		case Fri   = "Fri"
		case Sat   = "Sat"
		case Sun   = "Sun"
	}
}

extension Notification.Name {
	
	static let loggedIn           = Notification.Name("loggedIn")
	static let startedNewTable    = Notification.Name("startedNewTable")
	static let approvedTable      = Notification.Name("approvedTable")
	static let endedTable         = Notification.Name("endedTable")
	static let cancelledTable     = Notification.Name("cancelledTable")
    static let updatedUser        = Notification.Name("updatedUser")
	static let startedNewOrder 	  = Notification.Name("startedNewOrder")
	static let approvedOrder      = Notification.Name("approvedOrder")
	static let declinedOrder      = Notification.Name("declinedOrder")
	static let orderChanged       = Notification.Name("orderChanged")
	static let makingReservation  = Notification.Name("makingReservation")
	static let updateTimer        = Notification.Name("updateTimer")
	static let updateCancelTimer  = Notification.Name("updateCancelTimer")
	static let finishedPayment    = Notification.Name("finishedPayment")
}
