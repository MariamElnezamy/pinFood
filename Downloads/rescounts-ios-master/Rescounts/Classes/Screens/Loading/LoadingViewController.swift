//
//  LoadingViewController.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-15.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import Crashlytics

class LoadingViewController: UIViewController {
	
	var spinner = CircularLoadingSpinner()
	let logo = UIImageView(image: UIImage(named: "rescounts_videologo"))
	let fetchSyncGroup = DispatchGroup()
	
	let kSpinnerSize: CGFloat = 30
	
	
	// MARK: - UIViewController Methods
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .gold
		
		logo.frame = view.bounds
		logo.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		logo.contentMode = .scaleAspectFit
		view.addSubview(logo)
		
		spinner.colour = .dark
		spinner.frame = CGRect(floor(0.5 * (view.frame.width - kSpinnerSize)), floor(0.75 * view.frame.height - 0.5 * kSpinnerSize), kSpinnerSize, kSpinnerSize)
		spinner.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin]
		view.addSubview(spinner)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.setNavigationBarHidden(true, animated: true)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// If we're already logged in, just fetch data
		if AccountManager.main.token != nil {
			startFetchingData()
			
		// Otherwise if we have a saved token, refresh it before continuing
		} else if let authToken = UserDefaults.standard.string(forKey: Constants.UserDefaults.userAuthToken), let userDict = UserDefaults.standard.dictionary(forKey: Constants.UserDefaults.userDetails), let user = User.init(json: userDict) {
			refreshTokenThenFetchData(authToken, user)
		
		// Finally if not logged in and no saved token, go to the login screen
		} else {
			goBackToLogin()
		}
	}
	
	
	// MARK: - Private Helpers
	
	private func refreshTokenThenFetchData(_ authToken: String, _ user: User) {
		AccountManager.main.updateUser(token: authToken, user: user)
		
		UserService.refreshToken(token: authToken) { [weak self] error in
			if error == nil {
				//UNREVIEWED TAG
				self?.startFetchingData()
			} else {
				self?.goBackToLogin()
			}
		}
	}
	
	private func startFetchingData() {
		// Ensure all asynchronous tasks enter the dispatch group 'fetchSyncGroup'
		startLocationService()
		downloadUserData()
		
		// Synchronize the fetches and then move on
		fetchSyncGroup.notify(queue: DispatchQueue.main) { [weak self] () -> Void in
			if (AccountManager.main.user?.userID == "") {
				self?.goBackToLogin()
				
			} else if (AccountManager.main.user?.firstName == "" || AccountManager.main.user?.phoneNum == "" ) {
				self?.moveToNameScreen()
				RescountsAlert.showAlert(title: l10n("signUpReminderTitle"), text: l10n("namePhoneRequired"), callback: nil)
			}
			else if (OrderManager.main.unreviewedTable.ID != nil) {
				//UNREVIEWED TAG
				//There is an unreviewed table, go to the feedback/review page
				self?.moveToFeedbackScreen()
			// Disabling tutorial video autoplay on first start
//			} else if (!UserDefaults.standard.bool(forKey: Constants.UserDefaults.playedTutVideo)) {
//				self.moveToTutVideoScreen()
//				UserDefaults.standard.set(true, forKey: Constants.UserDefaults.playedTutVideo)
			}  else {
				self?.moveToNextScreen()
			}
		}
	}
	
	private func startLocationService() {
		fetchSyncGroup.enter()
		LocationManager.beginTracking { [weak self] (result: LocationCallbackResult) in
			if (result == .AuthError) {
				RescountsAlert.showAlert(title: l10n("locationRequiredTitle"), text: l10n("locationRequiredText"), options: [l10n("noThx"), l10n("goSettings")]) { (alert, buttonIndex) in
					self?.fetchSyncGroup.leave()
					
					guard buttonIndex == 1, let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
						return
					}
					
					if UIApplication.shared.canOpenURL(settingsUrl) {
						UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
						})
					}
				}
			} else {
				print("Location result: \(result)")
				self?.fetchSyncGroup.leave()
			}
		}
	}
	
	private func downloadUserData() {
		fetchSyncGroup.enter()
		
		UserService.fetchUserDetails() { [weak self] (user, error) in
			if let user = user {
				Crashlytics.sharedInstance().setUserEmail(user.email)
				Crashlytics.sharedInstance().setUserIdentifier(user.userID)
				Crashlytics.sharedInstance().setUserName("\(user.firstName) \(user.lastName)")
			}
			self?.restoreState()
			
			if let user = user {
				let defaults = UserDefaults.standard
				if let _ = defaults.object(forKey: Constants.UserDefaults.referralPoints) {
					let oldPoints = defaults.integer(forKey: Constants.UserDefaults.referralPoints)
					let newPoints = user.allTimeLoyaltyPointsReferral - oldPoints
					if newPoints > 0 {
						RescountsAlert.showAlert(title: "\(l10n("uVeGot")) \(newPoints) \(l10n("yourWinnings"))!",
												 text: "\(l10n("friendRefered")) \(l10n("congrats"))", icon: nil, postIconText: nil, options: [l10n("thx").uppercased()], callback: nil)
					}
				}
				
				defaults.set(user.allTimeLoyaltyPointsReferral, forKey: Constants.UserDefaults.referralPoints)
				defaults.synchronize()
			}
			
			// We now have the bonus info from the user to determine which notifications to schedule
			NotificationManager.startupTasks()
			
			self?.fetchSyncGroup.leave()
		}
	}
	
	private func restoreState() {
		fetchSyncGroup.enter()
		
		OrderManager.main.restoreTable() { [weak self] () in
			self?.fetchSyncGroup.leave()
		}
		//UNREVIEWED TAG
		//If the UNREVIEWED table id was assigned, there is an unreviewed table.
		if ( OrderManager.main.unreviewedTable.ID != nil ){
			fetchSyncGroup.enter()
			//Call table/{tableID} for restoring unreviewed tables and get the order.
			TableService.getTableStatus(tableID: OrderManager.main.unreviewedTable.ID ?? "") { [weak self](approved, error, response) in
				if let appro = approved, !appro {
					print("RESTORE UNREVIEWED TABLE FAILED: \(OrderManager.main.unreviewedTable.ID ?? "")" )
				}
				self?.fetchSyncGroup.leave()
			}
		}
	}
	
	private func moveToTutVideoScreen() {
		if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
			appDelegate.switchToTUTVideoScreens()
		}
	}
	
	private func moveToNextScreen() {
		if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
			appDelegate.switchToMainScreens(fromVC: self)
		}
	}
	
	private func goBackToLogin() {
		if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
			appDelegate.switchToLoginScreens()
			
			// We clear this here (and not other login info) because refreshToken failed. We don't want to clear their email (used to pre-fill login field),
			// but if they login as a different user, we would incorrectly show them a 'referral bonus' popup
			UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.referralPoints)
		}
	}
	
	private func moveToNameScreen() {
		if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
			appDelegate.switchToUserNameScreens(fromVC: self)
		}
	}
	
	
	//UNREVIEWED TAG
	public func moveToFeedbackScreen() {
		SearchService.fetchRestaurant(restaurantID: OrderManager.main.unreviewedTable.RestaurantID ?? "", callback: { (restaurant) in
			OrderManager.main.unreviewedTable.RestaurantName = restaurant?.name
			
			if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
				appDelegate.switchToFeedbackScreen()
			}
			
		})
	}
}
