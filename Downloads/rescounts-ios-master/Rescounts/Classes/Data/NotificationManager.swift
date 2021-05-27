//
//  NotificationManager.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-09-30.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
	
	public static let main = NotificationManager()
	
	//Notification actions
	static let goToAppStoreAction = UNNotificationAction(identifier: "goToAppStore", title: l10n("goAppStore"), options: [.foreground])
	static let NoAction = UNNotificationAction(identifier: "Cancel", title: l10n("noThx"), options: [.foreground])
	
	//Notification categories
	let CategoryA = UNNotificationCategory(identifier: Constants.Notification.categoryA,
												 actions: [goToAppStoreAction, NoAction],
												 intentIdentifiers: [], options: [])
	
	
	
	static let firstTimeReminderData: [(time: TimeInterval, message: String, identifier: String)] = [
		(60*60*24*3, l10n("discountRem4"), "3DayReminder"), // 3 days
		(60*60*24*5, l10n("discountRem2"), "5DayReminder"), // 5 days
		(60*60*24*6, l10n("discountRem1"),  "6DayReminder"), // 6 days
		(60*60*24*15, l10n("discountRem15"), "15DayReminder")] // 15 days
	
	static let kOneWeekInterval: TimeInterval = 60*60*24*7
	
	
	// MARK: - Public Methods
	
	public static func startupTasks() {
		UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert]) { (granted, error) in
			print ("Notification status: \(granted)")
			if let error = error {
				print("NOTIFICATION ERROR:  \(error.localizedDescription)")
			}
			
			scheduleNecessaryNotifications()
		}
	}
	
	private static func scheduleNecessaryNotifications() {
		print ("Cleaing old notifications");
		UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
		
		guard let user = AccountManager.main.user else {
			return
		}
		
		if UserDefaults.standard.bool(forKey: Constants.UserDefaults.disabledNotifications) {
			// Disabled, no point scheduling
			return
		}
		
		if user.firstOrderBonus {
			let installDate = UserDefaults.standard.object(forKey: Constants.UserDefaults.firstInstalledDate) as? Date ?? Date()
			
			for info in firstTimeReminderData {
				
				if (installDate.timeIntervalSinceNow > -info.time) {
				// It's sooner than this notification's appearance time, so schedule it
					
					scheduleNotification(at: installDate.addingTimeInterval(info.time),
										 title: l10n("firstBoxNotiTitle"),
										 text:  info.message,
										 identifier: info.identifier)
				}
			}
		}
		
		// Absent 1-week
		var message: String = ""
		if user.loyaltyPoints > 0 {
			message = l10n("unusedWinningNoti")
		} else {
			message = l10n("zeroWinningNoti")
		}
		scheduleNotification(at: Date().addingTimeInterval(kOneWeekInterval),
							 title: l10n("reminderNotiTitle"),
							 text:  message,
							 identifier: "1WeekReminder")
	}
	
	public static func notificationsEnabled(completion: @escaping (Bool, Bool)->()) {
		UNUserNotificationCenter.current().getNotificationSettings { (settings) in
			DispatchQueue.main.async {
				let globallyEnabled = settings.authorizationStatus != .notDetermined && settings.authorizationStatus != .denied
				let locallyEnabled = !UserDefaults.standard.bool(forKey: Constants.UserDefaults.disabledNotifications)
				
				completion(globallyEnabled, locallyEnabled)
			}
		}
	}
	
	public static func showMessageFrom(_ messages: [TargettedMessage]) {
		let defaults = UserDefaults.standard
		var shownMessageIDs = defaults.stringArray(forKey: Constants.UserDefaults.shownMessageIDs) ?? []
		var messageToShow: TargettedMessage?
		
		for message in messages {
			if (!shownMessageIDs.contains(message.messageID)) {
				messageToShow = message
				break;
			}
		}
		
		if let messageToShow = messageToShow {
			RescountsAlert.showAlert(title: messageToShow.title, text: messageToShow.message, icon: nil, postIconText: nil, options: ["OK"], callback: nil)
			
			shownMessageIDs.append(messageToShow.messageID)
			defaults.set(shownMessageIDs, forKey: Constants.UserDefaults.shownMessageIDs)
			defaults.synchronize()
		}
	}
	
	
	// MARK: - Private Helpers
	
	private static func scheduleNotification(at date: Date, title: String, text: String, identifier: String) {
		let calendar = Calendar(identifier: .gregorian)
		let components = calendar.dateComponents(in: .current, from: date)
		let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
		
		let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
		
		let content = UNMutableNotificationContent()
		content.title = title
		content.body = text
		
		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
		
		print ("Scheduling notification: \(identifier)  at: \(components.month ?? 0)-\(components.day ?? 0) \(components.hour ?? 0):\(components.minute ?? 0)")
		UNUserNotificationCenter.current().add(request) {(error) in
			if let error = error {
				print("Error scheduling notification: \(error)")
			}
		}
	}
	
	// MARK: - Local user notification methods
	
	func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
		
		//displaying the ios local notification when app is in foreground
		completionHandler([.alert, .badge, .sound])
	}
	func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
		switch response.actionIdentifier {
		case UNNotificationDismissActionIdentifier:
			print("Dismiss Action")
		case UNNotificationDefaultActionIdentifier:
			print("Default")
		case "goToAppStore":
			print("go to the app store")
			//TODO: navigate to the rating and review view on the app store, example URL is :
		//guard let writeReviewURL = URL(string: "https://itunes.apple.com/app/idXXXXXXXXXX?action=write-review")
		case "Cancel":
			print("doing nothing")
		case "textMessage" :
			print("sending the message: ")
		default:
			print("Unknown action")
		}
		
		completionHandler()
	}
}
