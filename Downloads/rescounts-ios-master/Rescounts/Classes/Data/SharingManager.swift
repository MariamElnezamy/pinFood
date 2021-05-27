//
//  SharingManager.swift
//  Rescounts
//
//  Created by Monica Luo on 2019-01-31.
//  Copyright © 2019 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import UIKit

class SharingManager : NSObject {
	private static let sharedInstance = SharingManager()
	
	private static let items: [Any] = [String.localizedStringWithFormat(l10n("shareMess"), "\(AccountManager.main.user?.sharingCode ?? "''")"), URL(string: "http://onelink.to/ynqm4g")!]
	
	public static func getSharingVC() -> UIActivityViewController {
		let vc = UIActivityViewController(activityItems: SharingManager.items, applicationActivities: nil)
		vc.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
			if !completed {
				return
			}
			
			if let trackingDict = GAIDictionaryBuilder.createEvent(withCategory: "action", action: "referred_friend", label: nil, value: nil)?.build() as? [AnyHashable : Any] {
				GAI.sharedInstance()?.defaultTracker.send(trackingDict)
			}
		}
		vc.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .saveToCameraRoll, .addToReadingList, .openInIBooks]
		return vc
	}
}
