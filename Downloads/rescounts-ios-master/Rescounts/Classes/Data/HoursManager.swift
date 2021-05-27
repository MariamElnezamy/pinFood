//
//  HoursManager.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-20.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

// MARK: - Hours
struct Hours {
	let open: String
	let close: String
	
	public func asString() -> String {
		return "\(open)-\(close)"
	}
}

class WeeklyHours: NSObject {
	
	private var dailyHours: [String: Hours] = [:]
	
	// MARK: - Initialization
	
	convenience init?(json: [[String: Any]]) {
		if json.count > 0 {
			self.init()
			
			for hoursDict in json {
				if  let openDict = hoursDict["open"] as? [String:Any],
					let closeDict = hoursDict["close"] as? [String:Any],
					let day = (openDict["day"] as? NSNumber)?.intValue,
					let open = openDict["time"] as? String,
					let close = closeDict["time"] as? String
				{
					let adjustedDay = (day + 6) % 7 // Change from 0=Sunday to 0=Monday
					dailyHours[HoursManager.orderedDaysOfWeekKeys()[adjustedDay].rawValue] = Hours(open: HoursManager.convertToAmPm(time:open), close: HoursManager.convertToAmPm(time:close))
				}
			}
		} else {
			return nil
		}
	}
	
	// MARK: - Public Getters
	
	public func todaysHours() -> Hours? {
		return hoursForDay(HoursManager.todaysKey())
	}
	
	public func hoursForDay(_ day: Constants.DayOfWeek) -> Hours? {
		return dailyHours[day.rawValue]
	}
	
	public func todaysHoursAsString() -> String {
		return hoursForDayAsString(HoursManager.todaysKey())
	}
	
	public func hoursForDayAsString(_ day: Constants.DayOfWeek) -> String {
		return hoursForDay(day)?.asString() ?? l10n("closed")
	}
}


// MARK: - HoursManager
class HoursManager: NSObject {
	
	//This is the timer for 3-minutes auto decline
	public static var minutes = 4
	public static var seconds = 60
	public static var timer = Timer()
	public static var isTimerRunning: Bool = false
	public static var shouldShowTimer: Bool = false
	public static var currentBackgroundDate = Date()
	
	//This is the timer for 15 minutes auto cancel table : the table has been accepted but hasn't submitted order for 15 minuts
	public static var autoCancelMinutes = 29 // 30 minutes
	public static var autoCancelSeconds = 60
	public static var autoCancelTimer = Timer()
	public static var isAutoCancelTimerRunning : Bool = false
	public static var currentBackgroundDateForAutoCancel = Date()
	
	//Refetching restaurants if user is out of browse page for more than 10 minues
	private static var theTenMinutsTimer : Date? = nil
	
	static let daysOfWeekKeys : [Constants.DayOfWeek] = [.Mon, .Tues, .Wed, .Thurs, .Fri, .Sat, .Sun]
	
	private static let hoursFormatter  = createFormatter("h:mma")
	private static let hoursParser     = createFormatter("yyyy-MM-dd h:mma")
	private static let dayFormatter    = createFormatter("yyyy-MM-dd")
	private static let birthdayFormatter = createFormatter("MMM-dd-yyyy")
	private static let dateResponseFormatter = createFormatter("yyyy-MM-dd\'T\'HH:mm:ss.SSSZ")
	private static let dateFormatter   = create8601Formatter() // "yyyy-MM-dd'THH:mm:ssZ" -> 2018-12-25T12:34:56Z
	private static let utcDateFormatter = create8601Formatter()
	private static let monthNames 		= DateFormatter().monthSymbols
	
	public static func orderedDaysOfWeekKeys() -> [Constants.DayOfWeek] {
		return daysOfWeekKeys
	}
	
	public static func todaysKey() -> Constants.DayOfWeek {
		let myCalendar = Calendar(identifier: .gregorian)
		let weekDay = (myCalendar.component(.weekday, from: Date()) + 5) % 7 // convert .weekday from (1=Sun,2=Mon,etc) to (0=Mon,1=Tue,etc)
		if 0...6 ~= weekDay {
			return orderedDaysOfWeekKeys()[weekDay]
		} else {
			assertionFailure("ERROR: Could not find today's key, returning default value!")
			return .Mon
		}
	}
	
	public static func allDaysAsString(_ hours: WeeklyHours?) -> String {
		var retVal = ""
		
		if let hours = hours {
			for day in daysOfWeekKeys {
				if (retVal.count > 0) {
					retVal += "\n"
				}
				retVal += "\(day):  \(hours.hoursForDayAsString(day))" // TODO: Use localized values for days, not the raw keys
			}
		}
		return retVal
	}
	
	public static func allDaysAsString(_ hours: WeeklyHours?) -> (days: String, hours: String) {
		var retValDays = ""
		var retValHours = ""
		
		if let hours = hours {
			for day in daysOfWeekKeys {
				if (retValDays.count > 0) {
					retValDays  += "\n\n"
					retValHours += "\n\n"
				}
				retValDays  += "\(day):" // TODO: Use localized values for days, not the raw keys
				retValHours += "\(hours.hoursForDayAsString(day))"
			}
		}
		return (retValDays, retValHours)
	}
	
	public static func getTenMinutesTimer() -> Date? {
		return theTenMinutsTimer
	}
	
	public static func setTenMinutesTimer() {
		theTenMinutsTimer = Date().adding(minutes: 5) //Due to Hany's request, change it from 10 to 5 minutes
	}
	
	@objc public static func updateTimer(){
		if seconds < 1 {
			minutes -= 1
			seconds = 60
			
		} else {
			self.seconds -= 1
			NotificationCenter.default.post(name: .updateTimer, object: nil)
		}
		
		if(minutes < 0) {
			timer.invalidate()
			resetTimer()
			
			guard let _ = OrderManager.main.currentRestaurant else {
				return // Prevent double pop-up, we might have auto-declined frmo the app and shown this popup already
			}
			
			SoundsMaker.main.alert()
			OrderManager.main.autoDeclineTable {
				var reason = OrderManager.main.orders.declinedReason
				reason = (reason == l10n("tableNoDeclinedDefault")) ? "" : "\(l10n("reason")): \(OrderManager.main.orders.declinedReason) \n\n"
				RescountsAlert.showAlert(title: String.localizedStringWithFormat(l10n("noTable"), "\(OrderManager.main.currentTable?.restaurantName ?? l10n("theRes"))"),
										 text: "\(reason)\(l10n("findElse"))",
										 callback:
					{ (alert, buttonIndex) in
						if let wd = UIApplication.shared.delegate?.window {
							var vc = wd!.rootViewController
							if (vc is UINavigationController) {
								vc = (vc as! UINavigationController).visibleViewController
							}
							if(vc is BrowseViewController) {
								// I am on BrowseViewController
							} else {
								//I'm not on browseviewController, go back to root view which is browseViewController
								vc?.navigationController?.popToRootViewController(animated: true)
							}
						}
				})
			}
		}
		
	}
	
	public static func pauseTimer(){
		HoursManager.timer.invalidate()
		HoursManager.isTimerRunning = false
		HoursManager.currentBackgroundDate = Date()
	}
	
	public static func resumeTimer(){
		let difference = HoursManager.currentBackgroundDate.timeIntervalSinceNow
		calculateTimeDifference(-difference)
		HoursManager.startTimer()
	}
	
	public static func calculateTimeDifference(_ interval: TimeInterval) {
		//set up the HoursManager with the correct time
		let ti = NSInteger(interval)
		let seconds = ti % 60
		let minutes = (ti / 60) % 60
		
		if HoursManager.seconds - seconds < 0 {
			let left = 60 + (HoursManager.seconds - seconds)
			HoursManager.minutes -= 1
			HoursManager.seconds = left
		} else {
			HoursManager.seconds = HoursManager.seconds - seconds
		}
		
		HoursManager.minutes -= minutes
	}
	
	public static func startTimer(){
		if (!HoursManager.isTimerRunning){
			HoursManager.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
			HoursManager.isTimerRunning = true
		}
	}
	
	public static func resetTimer(){
		HoursManager.isTimerRunning = false
		HoursManager.seconds = 60
		HoursManager.minutes = 4
		HoursManager.timer.invalidate()
	}
	
	//Auto cancel timer
	@objc public static func updateAutoCancelTimer(){
		if autoCancelSeconds < 1 {
			autoCancelMinutes -= 1
			autoCancelSeconds = 60
			
		} else {
			self.autoCancelSeconds -= 1
			NotificationCenter.default.post(name: .updateCancelTimer, object: nil)
		}
		
		if(autoCancelMinutes < 0) {
			autoCancelTimer.invalidate()
			
			// check if there is pending order.
				//should polling order by now, we don't need to do anything
			//If there is no pending order and no first confirmed order
				//Should start polling table
			if ((!OrderManager.main.orders.hasPendingItems) && (!OrderManager.main.orders.hasConfirmedItems)) {
				OrderManager.main.startPollingTableForAutoCancelCheck()
			} else {
				resetAutoCancelTimer() // If we have the order already, we stop the timer
			}
			
		}
		if (OrderManager.main.currentTable == nil){ // The table has been closed, cancel it at any time
			HoursManager.showEndAutoCancelTimerPopUp()
			HoursManager.resetAutoCancelTimer()
		}
		
		//print(getAutoCancelTimerString())
		
	}
	
	public static func pauseAutoCancelTimer(){
		HoursManager.autoCancelTimer.invalidate()
		HoursManager.isAutoCancelTimerRunning = false
		HoursManager.currentBackgroundDateForAutoCancel = Date()
	}
	
	public static func resetAutoCancelTimer() {
		HoursManager.isAutoCancelTimerRunning = false
		HoursManager.autoCancelSeconds = 60
		HoursManager.autoCancelMinutes = 29  // 30 minutes
		HoursManager.autoCancelTimer.invalidate()
		UserDefaults.standard.set(false, forKey: Constants.UserDefaults.autoCancelTimerRunning)
	}
	
	public static func resumeAutoCancelTimer(){
		let difference = HoursManager.currentBackgroundDateForAutoCancel.timeIntervalSinceNow
		calculateAutoCancelTimeDifference(-difference)
		HoursManager.startAutoCancelTimer()
	}
	
	public static func calculateAutoCancelTimeDifference(_ interval: TimeInterval) {
		//set up the HoursManager with the correct time
		let ti = NSInteger(interval)
		let seconds = ti % 60
		let minutes = (ti / 60) % 60
		
		if HoursManager.autoCancelSeconds - seconds < 0 {
			let left = 60 + (HoursManager.autoCancelSeconds - seconds)
			HoursManager.autoCancelMinutes -= 1
			HoursManager.autoCancelSeconds = left
		} else {
			HoursManager.autoCancelSeconds = HoursManager.autoCancelSeconds - seconds
		}
		
		HoursManager.autoCancelMinutes -= minutes
	}
	
	public static func startAutoCancelTimer(){
		if (!HoursManager.isAutoCancelTimerRunning){
			HoursManager.autoCancelTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateAutoCancelTimer)), userInfo: nil, repeats: true)
			HoursManager.isAutoCancelTimerRunning = true
		}
	}
	
	public static func showStartAutoCancelTimerPopUp() {
		RescountsAlert.showAlert(title: "", text: l10n("startAutoCancel"))
	}
	
	public static func showEndAutoCancelTimerPopUp() {
		RescountsAlert.showAlert(title: "", text: l10n("endAutoCancel"))
	}

	public static func getTimerString()->String {
		return String(format:"%01i:%02i",minutes, seconds)
	}
	
	public static func getAutoCancelTimerString()->String {
		return String(format:"%01i:%02i",autoCancelMinutes, autoCancelSeconds)
	}
	
	public static func dateFromHoursString(_ hours: String) -> Date? {
		hoursParser.locale = Locale(identifier: Constants.Location.identifier)
		return hoursParser.date(from: "\(todaysDateAsString()) \(hours)")
	}
	
	public static func hoursStringFromDate(_ date: Date) -> String {
		return hoursFormatter.string(from: date)
	}
	
	public static func dateFromString(_ dateString: String?) -> Date? {
		return dateFormatter.date(from: dateString?.trimmedIso8601Format() ?? "")
	}
	
	public static func stringFromDate(_ date: Date) -> String {
		return dayFormatter.string(from: date)
	}

    public static func stringFromDate8601(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
	
	public static func UTCToLocal(UTCDateString: String, dateFormat : String = "yyyy-MM-dd\'T\'HH:mm:ssZ") -> String {
		var UTCDate: Date = Date()
		if (dateFormat == "yyyy-MM-dd\'T\'HH:mm:ss.SSSZ"){
			dateResponseFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
			UTCDate = dateResponseFormatter.date(from: UTCDateString) ?? Date()
		} else {
			utcDateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
			UTCDate = utcDateFormatter.date(from: UTCDateString) ?? Date()
		}
		utcDateFormatter.timeZone = TimeZone.current
		let UTCToCurrentFormat = utcDateFormatter.string(from: UTCDate)
		return UTCToCurrentFormat
	}
	
	public static func localToUTC(date:String) -> String {
		utcDateFormatter.timeZone = TimeZone.current
		let dt = utcDateFormatter.date(from: date)
		utcDateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		return utcDateFormatter.string(from: dt!)
	}
	
	public static func userFriendlyBirthday(_ desiredTime: Date?) -> String {
		if (desiredTime == nil ){
			return ""
		} else {
			let realDate : Date = desiredTime ?? Date()
			let timeZone = TimeZone(identifier: "UTC")
			birthdayFormatter.timeZone = timeZone
			return birthdayFormatter.string(from: realDate)
			
		}
	}
	
	public static func userFriendlyDate(_ desiredTime: Date) -> String {
		var hour = Calendar.current.component(.hour, from: desiredTime)
		let minutes = Calendar.current.component(.minute, from: desiredTime)
		var tail : String = String()
		if hour > 12 {
			hour = hour - 12
			tail = "PM"
		} else {
			tail = (hour == 12) ? "PM" : "AM"
		}
		return "\(hour):\(String(format: "%02d", minutes))\(tail)"
	}
	
	
	// MARK: - Private Helpers
	
	private static func createFormatter(_ format: String) -> DateFormatter {
		let formatter = DateFormatter()
		
		formatter.dateFormat = format
		
		return formatter
	}
	
	private static func create8601Formatter() -> ISO8601DateFormatter {
		let formatter = ISO8601DateFormatter()
		
		// If i use .withFractionalSeconds, I always get back a Date object representing Jan 1, 2000 for some reason.
//		if #available (iOS 11.0, *) {
//			formatter.formatOptions = [.withFractionalSeconds]
//		}
		
		return formatter
	}
	
	
	private static func todaysDateAsString() -> String {
		return dayFormatter.string(from: Date())
	}
	
	fileprivate static func convertToAmPm(time: String) -> String {
		var retVal = time
		let hours = time.components(separatedBy: ":")
		
		if let hourStr = hours.first, let hour = Int(hourStr), hours.count >= 2 {
			var amPm = "AM"
			var moddedHour = hour
			
			if (hour == 0) {
				moddedHour = 12
			} else if (hour > 12) {
				moddedHour = hour - 12
				amPm = "PM"
			} else if (hour == 12) {
				amPm = "PM"
			}
			retVal = "\(moddedHour):\(hours[1])\(amPm)"
		}
		return retVal
	}
}
