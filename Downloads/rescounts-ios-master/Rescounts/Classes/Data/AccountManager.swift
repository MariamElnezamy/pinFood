//
//  AccountManager.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-05.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import FacebookLogin
import GoogleSignIn

class AccountManager: NSObject, GIDSignInDelegate {

	public static let main = AccountManager()
	
	public var user: User?
	public var token: String?
	public var tokenArg: String {
		return "Bearer \(AccountManager.main.token ?? "")"
	}
	
	public var onlyShowAvailable: Bool = false
	
	public func updateUser(token: String?, user: User?) {
        if let user = user {
			self.user = user
			UserDefaults.standard.set(user.email, forKey: Constants.UserDefaults.lastUsedEmail)
        }
        self.token = token
        UserDefaults.standard.set(self.user?.dictionaryRepresentation(), forKey: Constants.UserDefaults.userDetails)
        UserDefaults.standard.set(token, forKey: Constants.UserDefaults.userAuthToken)
		UserDefaults.standard.synchronize()
		NotificationCenter.default.post(name: .updatedUser, object: nil)
	}

    public func logout() {
        clearLoginInfo()
		
		if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
			appDelegate.switchToLoginScreens()
		}
    }
	
	public func clearLoginInfo() {
		self.user = nil
		self.token = nil
		UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.userDetails)
		UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.userAuthToken)
		UserDefaults.standard.removeObject(forKey: Constants.UserDefaults.referralPoints)
		UserDefaults.standard.synchronize()
		PaymentManager.main.applePayOption = false
		OrderManager.main.unreviewedTable.cleanOut()
		OrderManager.main.clearTable()
		
		URLCache.shared.removeAllCachedResponses()
		
		GIDSignIn.sharedInstance().signOut()
		LoginManager().logOut()
	}
	
	public func cleanCache(_ url: URL){
		let cstorage = HTTPCookieStorage.shared
		if let cookies = cstorage.cookies(for: url) {
			for cookie in cookies {
				cstorage.deleteCookie(cookie)
			}
		}
	}
	
	public func showLoginUI(from presenter: UIViewController) {
		RescountsAlert.showAlert(title: "Account Required", text: "You need to create a profile to be able to place an order.", options: ["Cancel", "Create"]) { (alert, buttonIndex) in
			if buttonIndex == 1 {
				let vc = IntroViewController()
				let nc = BaseNavigationController(rootViewController: vc)
				presenter.present(nc, animated: true, completion: nil)
			}
		}
	}
	
//	public class func user() -> User? {
//		return sharedInstance.user
//	}
	
	// MARK: - GIDSignInDelegate
	
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
			  withError error: Error!) {
		if let error = error {
			print("\(error.localizedDescription)")
		} else {
			UserService.login(googleToken: user.authentication.accessToken) { (user, error) in
				if let error = error {
					RescountsAlert.showAlert(title: l10n("loginErrorTitle"), text: error.localizedDescription)
				}
			}
		}
	}
	
	func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
	}
}
