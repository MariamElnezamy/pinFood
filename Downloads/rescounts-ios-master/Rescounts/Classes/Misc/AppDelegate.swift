//
//  AppDelegate.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-06.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import Stripe
import FBSDKCoreKit
import GoogleSignIn
import Fabric
import Crashlytics
import UserNotifications
import AVFoundation
import Firebase
import CardScan
#if DEBUG
import netfox
#endif
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var appClosedAt: Date? = nil
	var lastClearedTokens: Date?


	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		#if targetEnvironment(simulator)
			print("App Dir: \(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])")
			DebugTests.runDebugTests()
		#endif
		FirebaseApp.configure()
		keepBackgroundMusicPlaying()
        #if DEBUG
            NFX.sharedInstance().start()
        #endif
		setupEnvironmentToProd(true)
		setupStripe()
		
		FBSDKApplicationDelegate.sharedInstance()?.application(application, didFinishLaunchingWithOptions: launchOptions)
		
		GIDSignIn.sharedInstance().clientID = "333352463928-rdtf8kivdpr3i97ensm5uvprhp4a0k3a.apps.googleusercontent.com"
		GIDSignIn.sharedInstance().delegate = AccountManager.main;
		
		recordStartupStats()

		window = UIWindow(frame: UIScreen.main.bounds)
        
		if UserDefaults.standard.string(forKey: Constants.UserDefaults.userAuthToken) == nil {
			switchToIntroScreens(showAnimation: true)
		} else {
			switchToLoadingScreens(showAnimation: true)
		}
		
		VideoMaker.main.setUp()

		window?.makeKeyAndVisible()
		
		Fabric.with([Crashlytics.self])

		// Optional: automatically report uncaught exceptions.
		// gai.trackUncaughtExceptions = true

		// Optional: set Logger to VERBOSE for debug information.
		// Remove before app release.
		// gai.logger.logLevel = .verbose;
		
		//Set up the local notification center delegate
		UNUserNotificationCenter.current().delegate = NotificationManager.main

		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		pauseAutoCancelTimer()
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		appClosedAt = Date()
        
        if lastClearedTokens == nil {
        lastClearedTokens = Date()
        }
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Check if we need to refresh all the data.
		//	- We refresh if:
		//		- the user has an active order
		//		- they're 3 hours past the seating time OR (they have no pending items AND the app has been closed for at least 10 minutes)
		if let table = OrderManager.main.currentTable {
			if (table.seatingAt.timeIntervalSinceNow < -60*60*3) {
				switchToLoadingScreens()
			} else if let closedAt = appClosedAt, closedAt.timeIntervalSinceNow < -60*10, !OrderManager.main.hasPendingData { // 10 minutes
				switchToLoadingScreens()
			}
        }

		if let lastCleared = lastClearedTokens, -(lastCleared.timeIntervalSinceNow) < 60*60*6 {
			DispatchQueue.clearOnceToken("ShowTargettedMessage")
			lastClearedTokens = Date()
		}
		
		//resumeAutoCancelTimer()
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		//Resume timer for auto cancel timer
		resumeAutoCancelTimer()
	}

	func applicationWillTerminate(_ application: UIApplication) {
		pauseAutoCancelTimer()
		
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		var retVal =
			FBSDKApplicationDelegate.sharedInstance()?.application(app,
																   open: url,
																   sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
																   annotation: options[UIApplicationOpenURLOptionsKey.annotation]) ?? false
		if (!retVal) {
			retVal = GIDSignIn.sharedInstance().handle(url as URL?,
													   sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
													   annotation: options[UIApplicationOpenURLOptionsKey.annotation])
		}
		
		return retVal
	}

	
	// MARK: - Private Methods
	
	//for auto cancel table
	func pauseAutoCancelTimer() {
		//Check HoursManager.isAutoCancelTimerRunning is true or not. If it's true, we need to resume autocancel timer
		if HoursManager.isAutoCancelTimerRunning {
			HoursManager.pauseAutoCancelTimer()
			UserDefaults.standard.set(true, forKey: Constants.UserDefaults.autoCancelTimerRunning)
			UserDefaults.standard.set(HoursManager.currentBackgroundDateForAutoCancel, forKey: Constants.UserDefaults.autoCancelTime )
		} else {
			UserDefaults.standard.set(false, forKey: Constants.UserDefaults.autoCancelTimerRunning)
		}
	}
	
	func resumeAutoCancelTimer() {
		//resume timer for auto cancel timer
		let running : Bool = UserDefaults.standard.bool(forKey: Constants.UserDefaults.autoCancelTimerRunning)
		if running {
			/*if (OrderManager.main.currentTable == nil){ // The table has been closed
				HoursManager.showEndAutoCancelTimerPopUp()
				HoursManager.resetAutoCancelTimer()
			} else */ if let date = UserDefaults.standard.object(forKey: Constants.UserDefaults.autoCancelTime) as? Date {
				HoursManager.currentBackgroundDateForAutoCancel = date
				HoursManager.resumeAutoCancelTimer()
			}
		}
	}
	
	func switchToIntroScreens(showAnimation: Bool = false) {
		let vc = IntroViewController()
		if (showAnimation == false) {
			let nc = BaseNavigationController(rootViewController: vc)
			nc.setNavigationBarHidden(true, animated: false)
			setRootVC(nc)
		} else {
			let ac = LogoAnimationViewController(to: vc)
			let nc = BaseNavigationController(rootViewController: ac)
			nc.setNavigationBarHidden(true, animated: false)
			setRootVC(nc)
		}
	}
	
	func switchToLoginScreens() {
		let prevVc = IntroViewController()
		let vc = LoginViewController()
		let nc = BaseNavigationController(rootViewController: prevVc)
		nc.viewControllers = [prevVc, vc]
		nc.setNavigationBarHidden(true, animated: false)
		
		setRootVC(nc)
	}
	
	func switchToLoadingScreens(showAnimation: Bool = false) {
		let vc = LoadingViewController()
		if (showAnimation == false) {
			let nc = BaseNavigationController(rootViewController: vc)
			nc.setNavigationBarHidden(true, animated: false)
			setRootVC(nc)
		} else {
			let ac = LogoAnimationViewController(to: vc)
			let nc = BaseNavigationController(rootViewController: ac)
			nc.setNavigationBarHidden(true, animated: false)
		
			setRootVC(nc)
		}
	}
	
	func switchToTUTVideoScreens() {
		let pre = BrowseViewController()
		let videoView = TutorialVideoViewController(to: pre)
		
		setRootVC(videoView)
	}
	
	func switchToMainScreens(fromVC: UIViewController? = nil) {
		if let _ = fromVC?.presentingViewController {
			fromVC?.dismiss(animated: true, completion: nil)
		} else {
			let vc = BrowseViewController()
			let nc = BaseNavigationController(rootViewController: vc)
			
			setRootVC(nc)
		}
	}
	
	func switchToUserNameScreens(fromVC: UIViewController? = nil) {
		let vc = SignUpContinueViewController()
		
		if  let nc = fromVC?.navigationController,
			let introVC = nc.viewControllers.first as? IntroViewController,
			let currentVC = nc.viewControllers.last,
			introVC != currentVC
		{
			// We already have an appropriate navigation stack, so no need to change the window's root VC, just pop
			nc.viewControllers = [introVC, vc, currentVC]
			nc.popViewController(animated: true)
			
		} else {
			let preVc1 = IntroViewController()
			let preVc2 = LoginViewController()
			let nc = BaseNavigationController(rootViewController: preVc1)
			nc.viewControllers = [preVc1, preVc2, vc]
			
			setRootVC(nc)
		}
	}
	
	func switchToPaymentScreens() {
		let vc = PaymentMethodsViewController()
		vc.displayState = PaymentMethodsViewController.DisplayState.signup
		let nc = BaseNavigationController(rootViewController: vc)
		
		setRootVC(nc)
	}
	//UNREVIEWED TAG
	func switchToFeedbackScreen() {
		let vc = FeedbackViewController(tableID: OrderManager.main.unreviewedTable.ID ?? "", restaurantName : OrderManager.main.unreviewedTable.RestaurantName ?? "", serverName : OrderManager.main.unreviewedTable.Waiter ?? "",  price : OrderManager.main.unreviewedTable.TotalPrice ?? 0, unreviewed: true )
		let nc = BaseNavigationController(rootViewController: vc)
		nc.setNavigationBarHidden(true, animated: false)
		
		setRootVC(nc)
	}
	
	private func setRootVC(_ vc: UIViewController) {
		// After showing a modal, the old VCs don't seem to get cleared when setting the window's rootVC (2019-06-20)
		//	- so we clear them manually
		window?.removeAllSubviews()
		window?.rootViewController = vc
	}
	
	func setupEnvironmentToProd(_ isProd: Bool) {
		if (isProd) {
			BaseService.kHostName = "https://api.rescounts.com/"
			Constants.Stripe.stripePublishableKey = "pk_live_i6YbUBsgBHnR65vi2JXzelFj"
		} else {
			Helper.assertTestBuild()
			BaseService.kHostName = "http://192.168.0.4:8088/"
			Constants.Stripe.stripePublishableKey = "pk_test_kIDozUrRDueAQd7fl36alfGT"
		}
		
		if let gai = GAI.sharedInstance() {
			// We only use the live tracking ID if it's a release build targetting the production environment
			let trackerID = (isProd && Helper.isProduction()) ? "UA-127516975-1" : "UA-127531186-1"
			gai.tracker(withTrackingId: trackerID)
		} else {
			assert(false, "Google Analytics not configured correctly")
		}
	}
	
	func setupStripe() {
		assert(Constants.Stripe.stripePublishableKey.hasPrefix("pk_"), "Invalid Stripe Publishable Key. Check Constants.swift.")
		assert(Constants.Stripe.backendBaseURL != nil, "Invalid Stripe BackendBaseURL. Check Constants.swift.")
		STPPaymentConfiguration.shared().publishableKey = Constants.Stripe.stripePublishableKey
		STPPaymentConfiguration.shared().appleMerchantIdentifier = Constants.Stripe.appleMerchantID
		StripeAPIClient.sharedClient.baseURLString = Constants.Stripe.backendBaseURL
		STPPaymentConfiguration.shared().companyName = "Rescounts"
        ScanViewController.configure(apiKey: Constants.Stripe.stripePublishableKey)

	}
	
	private func recordStartupStats() {
		let defaults = UserDefaults.standard
		
		if (defaults.string(forKey: Constants.UserDefaults.firstInstalledVersion) == nil) {
			if let version = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
				defaults.set(version, forKey: Constants.UserDefaults.firstInstalledVersion)
			}
		}
		
		if (defaults.object(forKey: Constants.UserDefaults.firstInstalledDate) as? Date == nil) {
			defaults.set(Date(), forKey: Constants.UserDefaults.firstInstalledDate)
		}
		
		UserDefaults.standard.synchronize()
	}
	
	private func keepBackgroundMusicPlaying() {
		do {
			try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
			try AVAudioSession.sharedInstance().setActive(true)
		}
		catch let error as NSError {
			print(error)
		}
    }
    
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        // if you are planning to embed scanViewController into a navigation
        // controller, put this line to handle rotations
        return ScanBaseViewController.supportedOrientationMaskOrDefault()
    }
}

