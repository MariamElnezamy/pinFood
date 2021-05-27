//
//  UserService.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-08-18.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import Alamofire
import Stripe

class UserService: BaseService {
	
	typealias LoginCallback = (User?, Error?) -> Void
	typealias ReviewsCallback = ([RestaurantReview]?, Error?) -> Void
	
	static var unreviewedTableId = ""
	static var open: Bool = true
	
	static func login(email: String = "", password: String = "", callback: @escaping LoginCallback) {
		let args = ["email": email, "password": password]
		login(args: args, callback: callback)
	}
	
	static func login(fbToken: String, callback: @escaping LoginCallback) {
		let args = ["facebookToken": fbToken]
		login(args: args, callback: callback)
	}
	
	static func login(googleToken: String, callback: @escaping LoginCallback) {
		let args = ["googleToken": googleToken]
		login(args: args, callback: callback)
	}
    static func login(appleToken: String, callback: @escaping LoginCallback) {
        let args = ["appleToken": appleToken]
        login(args: args, callback: callback)
    }
	
	private static func login(args: [String: Any], callback: @escaping LoginCallback) {
		if useTestData() {
			loginWithFakeUser(callback: callback)
			return
		}
		
		guard let url = urlWith(path:"users/login") else {
            
			print ("LOGIN ERROR: Invalid URL.")
			loginFailed(error: nil, callback: callback)
			return
		}
        print(">>>>>\(url)")
        print(">>>>>>>\(args)")
		let headers: HTTPHeaders = [
			"Content-Type": "application/json"
		]
		
		Alamofire.request(url, method: .post, parameters: args, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
			guard let httpResponse = response.response else {
				print ("LOGIN ERROR: Could not reach server.")
				loginFailed(error: loginError(l10n("couldNotReachServer")), callback: callback)
				return
			}
			printStatus("Login", httpResponse.statusCode)
			
			if httpResponse.statusCode == 409 {
				print ("LOGIN ERROR: User already exists.")
				loginFailed(error: loginError(l10n("userAlreadyExists")), callback: callback)
				return
			}
			
			guard let json = response.result.value as? [String: Any] else {
				print ("LOGIN ERROR: Invalid JSON.")
				loginFailed(error: loginError(), callback: callback)
				return
			}
			
			guard let token = json["token"] as? String else {
				loginFailed(error: loginError((httpResponse.statusCode == 401) ? l10n("loginErrorText") : nil), callback: callback)
				return
			}
			
			var user: User? = nil
			if let userJson = json["user"] as? [String: Any] {
				user = User(json: userJson)
                
			}
			
			//UNREVIEWED TAG
			checkedStatusForUnreviewed(json: json)
			if ((unreviewedTableId != "") && (!open)) { //Assign the unreviewed table id
				OrderManager.main.unreviewedTable.ID = unreviewedTableId
			} else {
				OrderManager.main.unreviewedTable.ID = nil
			}
			
			AccountManager.main.updateUser(token: token, user: user)
			
			callback(user, nil)
			
			if (user != nil) {
				NotificationCenter.default.post(name: .loggedIn, object: nil)
			}
		}
	}
	
	static private func loginFailed(error: Error?, callback: @escaping LoginCallback) {
		AccountManager.main.clearLoginInfo()
		callback(nil, error)
	}

	static func updateUser(email: String? = nil, firstName: String? = nil, lastName:String? = nil, password: String? = nil, phoneNum: String? = nil, birthday: Date? = nil, promoCode : String? = nil, rtyCode : String? = nil, profile: String? = nil, review: Int? = nil, paymentMethod: String? = nil, stripeToken: STPToken? = nil,  allowOffers: Bool? = nil, city: String? = nil, callback: @escaping LoginCallback) {
        guard let url = urlWith(path:"users/\(AccountManager.main.user?.userID ?? "")") else {
            print ("UPDATE USER ERROR: Invalid URL.")
            callback(nil, nil)
            return
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": AccountManager.main.tokenArg
        ]

		var args: [String: Any] = [:]
		if let email = email {
			args["email"] = email
		}
		if let firstName = firstName {
			args["firstName"] = firstName
		}
		if let lastName = lastName {
			args["lastName"] = lastName
		}
		if let password = password {
			args["password"] = password
		}
		if let profile = profile {
			args["profile"] = profile
		}
		if let review = review {
			args["review"] = review
		}
		if let stripeToken = stripeToken {
			args["token"] = stripeToken.tokenId
		}
		if let phoneNum = phoneNum {
			args["phoneNumber"] = phoneNum
		}
		if let birthday = birthday {
			args["dateOfBirth"] = HoursManager.stringFromDate8601(birthday)
		}
		if let promoCode = promoCode {
			args["piCode"] = promoCode
		}
		if let rtyCode = rtyCode {
			args["rtyCode"] = rtyCode
		}
		if let allowOffers = allowOffers {
			args["allowsPromotions"] = allowOffers
		} else {
			args["allowsPromotions"] = AccountManager.main.user?.allowsOffer
		}
		if let city = city {
			args["homeCity"] = city
		}
		
		
		if let paymentMethod = paymentMethod { //TODO: not too sure if we need this one here, apple pay user will update token to submit order, no need for payment method
			args["paymentMethod"] = paymentMethod //if they want to switch to creidit card user, they would call updatePaymentMethod with token and payment method
												// if it's the first time they setup credit card, they would call updatePaymentMethod too
												// if they want to switch to apple pay from credit card user, they will call updatePaymentMethod with paymentmethod.
												// so this part is not use yet
		}

        Alamofire.request(url, method: .patch, parameters: args, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            guard let httpResponse = response.response else {
                print ("UPDATE USER ERROR: Could not reach server.")
                callback(nil, loginError(l10n("couldNotReachServer")))
                return
            }
            printStatus("Update User", httpResponse.statusCode)

            guard let json = response.result.value as? [String: Any] else {
                print ("UPDATE USER ERROR: Invalid JSON.")
                callback(nil, loginError())
                return
            }

            // Invalid token
            if httpResponse.statusCode == 403 {
                AccountManager.main.logout()
                callback(nil, loginError(l10n("wrongUser"), code: httpResponse.statusCode))
                return
            }
			
			//RTY error state
			if httpResponse.statusCode == 404 {
				//RTY Code doesn't match any restaurant.
				if let errorMessage = json["error"] as? String, errorMessage == "restaurant not found" {
					callback(nil, loginError("resNotFound"))
					
				} else { //Generall not found error
					callback(nil, loginError())
				}
				return
			}

            if httpResponse.statusCode == 200 {
                if let userID = json["id"] as? String, let email = json["email"] as? String{
					// TODO: this is hacky, we should generate a new User object from the JSON and apply it to the Manager, otherwise we're defining JSON keys twice and duplicating parsing logic
                    AccountManager.main.user?.userID = userID
                    AccountManager.main.user?.firstName = json["firstName"] as? String ?? ""
                    AccountManager.main.user?.lastName = json["lastName"] as? String ?? ""
                    AccountManager.main.user?.email = email
					AccountManager.main.user?.phoneNum = phoneNum ?? ""
					AccountManager.main.user?.birthday = birthday ?? nil
					AccountManager.main.user?.promoCode = promoCode ?? ""
					AccountManager.main.user?.allowsOffer = json["allowsPromotions"] as? Bool ?? false
					if let paymentSources = (json["paymentSources"] as? [[String: Any]] )?.first, let cardInfo = paymentSources["card"] as? [String : Any] {
						AccountManager.main.user?.card = Card(json: cardInfo )
					}
                    callback(AccountManager.main.user, nil)
                } else {
                    callback(nil, loginError("Invalid account returned from server."))
                }
            } else {
                callback(nil, loginError())
                return
            }
        }
    }
	
	// This is where to update payment method place
	static func updatePaymentMethod(method: String, tokenID: String? = nil, callback: @escaping LoginCallback){
		guard let url = urlWith(path:"users/\(AccountManager.main.user?.userID ?? "")") else {
			print ("UPDATE USER ERROR: Invalid URL.")
			callback(nil, nil)
			return
		}
		
		let headers: HTTPHeaders = [
			"Content-Type": "application/json",
			"Authorization": AccountManager.main.tokenArg
		]
		
		var args: [String: Any] = [:]
		args["paymentMethod"] = method

		if let tokenID = tokenID {
			args["token"] = tokenID
		}
		
		args["piCode"] = AccountManager.main.user?.promoCode
		args["allowsPromotions"] = AccountManager.main.user?.allowsOffer
		
		Alamofire.request(url, method: .patch, parameters: args, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
			guard let httpResponse = response.response else {
				print ("UPDATE USER ERROR: Could not reach server.")
				callback(nil, loginError(l10n("couldNotReachServer")))
				return
			}
			printStatus("Update User payment method", httpResponse.statusCode)
			
			guard let json = response.result.value as? [String: Any] else {
				print ("UPDATE USER ERROR: Invalid JSON.")
				callback(nil, loginError())
				return
			}
			
			//Invalid token
			if httpResponse.statusCode == 403 {
				AccountManager.main.logout()
				callback(nil, loginError(l10n("wrongUser"), code: httpResponse.statusCode))
				return
			}
			
			if httpResponse.statusCode == 200 {
				if let userID = json["id"] as? String, AccountManager.main.user?.userID == userID{
					if let methodInfo = json["paymentMethod"] as? String {
						if (methodInfo == Constants.PaymentOption.apple) {
							PaymentManager.main.applePayOption = true
							AccountManager.main.user?.card = nil
						} else { // This one should go credit card
							PaymentManager.main.applePayOption = false
							if let paymentSources = (json["paymentSources"] as? [[String: Any]] )?.first,  let cardInfo = paymentSources["card"] as? [String : Any]{ //the card might be nil for token is DELETE_ALL_TOKEN
								AccountManager.main.user?.card = Card(json: cardInfo )
							} else {
								AccountManager.main.user?.card = nil //Since the card is nil, should set up the card to be nil?
							}
						}
					}
					callback(AccountManager.main.user, nil)
				} else {
					callback(nil, loginError("Invalid account returned from server."))
				}
			} else {
				callback(nil, loginError("Uknown error (\(httpResponse.statusCode)) updating credit card, could not update user."))
				return
			}
		}
		
	}

    static func createUser(email: String, firstName: String = "", lastName: String = "", password: String, profile: String = "", callback: @escaping LoginCallback) {
        guard let url = urlWith(path:"users") else {
            print ("CREATE USER ERROR: Invalid URL.")
            callback(nil, nil)
            return
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json"
        ]

        let args: [String: Any] = ["email": email, "firstName": firstName, "id": "", "lastName": lastName, "password": password, "profile": profile, "review": 0]

        Alamofire.request(url, method: .post, parameters: args, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            guard let httpResponse = response.response else {
                print ("CREATE USER ERROR: Could not reach server.")
                callback(nil, loginError(l10n("couldNotReachServer")))
                return
            }
            printStatus("Create User", httpResponse.statusCode)

            guard let json = response.result.value as? [String: Any] else {
                print ("CREATE USER ERROR: Invalid JSON.")
                callback(nil, loginError())
                return
            }

            guard let token = json["token"] as? String else {
                callback(nil, loginError((httpResponse.statusCode == 401) ? l10n("loginFailed") :
										 (httpResponse.statusCode == 409) ? l10n("userAlreadyExists") : nil))
                return
            }
            if httpResponse.statusCode == 201 {
                var user: User? = nil
                if let userJson = json["user"] as? [String: Any] {
                    user = User(json: userJson)
                }

                AccountManager.main.updateUser(token: token, user: user)

                callback(user, nil)
            }
        }
    }

    static func refreshToken(token: String, callback: @escaping (Error?) -> Void) {
        guard let url = urlWith(path:"users/refresh") else {
            print ("REFRESH TOKEN ERROR: Invalid URL.")
            callback(loginError("Invalid URL."))
            return
        }

        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(token)"
            ]

        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            guard let httpResponse = response.response else {
                print ("REFRESH TOKEN ERROR: Could not reach server.")
                callback(loginError(l10n("couldNotReachServer")))
                return
            }
            printStatus("Refresh Token", httpResponse.statusCode)

            guard let json = response.result.value as? [String: Any] else {
                print ("REFRESH TOKEN ERROR: Invalid JSON.")
                callback(loginError())
                return
            }

            guard let token = json["token"] as? String else {
                callback(loginError((httpResponse.statusCode == 401) ? l10n("loginFailed") : nil))
                return
            }
			//UNREVIEWED TAG
			//Check if there is an UNREVIEWED table
			checkedStatusForUnreviewed(json: json)

            if 200 ... 299 ~= httpResponse.statusCode  {
                AccountManager.main.token = token
				//UNREVIEWED TAG
				if ((unreviewedTableId != "") && (!open)) { //Assign the unreviewed table id
					OrderManager.main.unreviewedTable.ID = unreviewedTableId
				} else {
					OrderManager.main.unreviewedTable.ID = nil
				}
                callback(nil)
			} else {
				callback(loginError("Could not refresh token."))
			}
        }
    }
	
	static func fetchUserDetails(callback: @escaping LoginCallback) {
		if useTestData() {
			loginWithFakeUser(callback: callback)
			return
		}
		
		guard let userID = AccountManager.main.user?.userID else {
			print ("FETCH USER ERROR: Missing user.")
			callback(nil, nil)
			return
		}
		
		guard let url = urlWith(path:"users/\(userID)") else {
			print ("FETCH USER ERROR: Invalid URL.")
			callback(nil, nil)
			return
		}
		
		let headers: HTTPHeaders = [
			"Content-Type": "application/json",
			"Authorization": AccountManager.main.tokenArg
		]
		
		// TODO: handle other currencies later
		let args: [String: Any] = ["currency": "CAD"]
		
		Alamofire.request(url, parameters: args, /*encoding: JSONEncoding.default,*/ headers: headers).responseJSON { response in
			guard let httpResponse = response.response else {
				print ("FETCH USER ERROR: Could not reach server.")
				callback(nil, loginError(l10n("couldNotReachServer")))
				return
			}
			printStatus("Fetch User", httpResponse.statusCode)
			
			guard let json = response.result.value as? [String: Any] else {
				print ("FETCH USER ERROR: Invalid JSON.")
				callback(nil, loginError())
				return
			}
			
			let user = User(json: json)
			
			AccountManager.main.updateUser(token: AccountManager.main.token, user: user)
			
			callback(user, nil)
		}
	}

    static func setProfilePicture(profilePicture: UIImage, callback: @escaping (Error?) -> Void) {
        guard let url = urlWith(path:"users/\(AccountManager.main.user?.userID ?? "")/picture") else {
            print ("SET PROFILE PICTURE: Invalid URL.")
            callback(loginError("Invalid URL."))
            return
        }

        let headers: HTTPHeaders = [
            "Content-Type": "image/jpeg",
            "Authorization": AccountManager.main.tokenArg
        ]

        if let imageData = UIImageJPEGRepresentation(profilePicture, 0.1) {
            Alamofire.upload(imageData, to: url, method: .post, headers: headers).responseJSON { response in
                guard let httpResponse = response.response else {
                    print ("SET PROFILE PICTURE: Could not reach server.")
                    callback(loginError(l10n("couldNotReachServer")))
                    return
                }
                printStatus("SET PROFILE PICTURE", httpResponse.statusCode)

                guard let json = response.result.value as? [String: Any] else {
                    print ("REFRESH TOKEN ERROR: Invalid JSON.")
                    callback(loginError())
                    return
                }

                //Invalid token
                if httpResponse.statusCode == 403 {
                    AccountManager.main.logout()
                    callback(loginError(l10n("wrongUser"), code: httpResponse.statusCode))
                    return
                }

                if 200 ... 299 ~= httpResponse.statusCode  {
                    AccountManager.main.user?.profileImage = URL(string: (json["profile"] as? String) ?? "")
                    callback(nil)
                } else {
                    callback(loginError())
                    return
                }
            }
        }
    }
	
	static func referFriend(sharingCode: String, callback: @escaping (Error?) -> Void) {
		guard let url = urlWith(path:"users/\(AccountManager.main.user?.userID ?? "")/referrer") else {
			print ("REFER FRIEND: Invalid URL.")
			callback(loginError("User ID is invalid. Try restarting the app."))
			return
		}
		
		guard sharingCode.count > 0 else {
			print ("REFER FRIEND: Zero-length sharing code.")
			callback(loginError("Missing sharing code!"))
			return
		}
		
		let headers: HTTPHeaders = [
			"Content-Type": "application/json",
			"Authorization": AccountManager.main.tokenArg
		]
		
		let args: [String: Any] = ["referralCode": sharingCode.uppercased()]
		
		Alamofire.request(url, method: .post, parameters:args, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
			guard let httpResponse = response.response else {
				print ("REFER FRIEND ERROR: Could not reach server.")
				callback(loginError("Could not reach the server. Please try again later."))
				return
			}
			printStatus("Refer friend", httpResponse.statusCode)
			
//			guard let _ = response.result.value as? [String: Any] else {
//				print ("REFER FRIEND ERROR: Invalid JSON.")
//				callback(loginError("Invalid JSON."))
//				return
//			}
			
			if 200 ... 299 ~= httpResponse.statusCode  {
				callback(nil)
			} else if 404 == httpResponse.statusCode  {
				callback(loginError(l10n("sharingWrongCode")))
			} else if 409 == httpResponse.statusCode  {
				callback(loginError(l10n("sharingAlreadyShared")))
			} else {
				callback(loginError(l10n("sharingGeneric")))
			}
		}
	}
	
	static func logout() {
		guard let url = urlWith(path:"users/logout") else {
			print ("LOGOUT ERROR: Invalid URL.")
			return
		}
		
		Alamofire.request(url)
		AccountManager.main.logout()
	}
	
	static func fetchMyReviews(callback: @escaping ReviewsCallback) {
//		guard let userID = AccountManager.main.user?.userID else {
//			print ("FETCH MY REVIEWS ERROR: Missing user.")
//			callback(nil, nil)
//			return
//		}
		
		// TODO: Fix this method and then actually use it.
		assert(false, "Not setup yet with actual user.")
		
		guard let url = urlWith(path:"restaurants/55ae3c93-afc3-46e7-82df-9ab38221d122/reviews") else { // TODO: change to actual user review endpoint
			print ("FETCH MY REVIEWS ERROR: Invalid URL.")
			callback(nil, nil)
			return
		}
		
		let headers: HTTPHeaders = [
			"Content-Type": "application/json",
			"Authorization": AccountManager.main.tokenArg
		]
		
		Alamofire.request(url, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
			guard let httpResponse = response.response else {
				print ("FETCH MY REVIEWS ERROR: Could not reach server.")
				callback(nil, loginError(l10n("couldNotReachServer")))
				return
			}
			printStatus("Fetch My Reviews", httpResponse.statusCode)
			
			guard let json = response.result.value as? [String: Any] else {
				print ("FETCH MY REVIEWS ERROR: Invalid JSON.")
				callback(nil, loginError())
				return
			}
			
			var results: [RestaurantReview] = []
			(json["reviews"] as? [[String:Any]])?.forEach { (reviewJSON) in
				if let review = RestaurantReview(json: reviewJSON) {
					results.append(review)
				}
			}
			
			callback(results, nil)
		}
	}
	
	static func forgotPassword(email: String, callback: @escaping (Error?) -> Void) {
		guard let url = urlWith(path:"users/forgotPassword") else {
			print ("FORGOT PASSWORD: Invalid URL.")
			callback(loginError("Functionality temporarily down."))
			return
		}
		
		guard email.count > 0 else {
			print ("FORGOT PASSWORD: Zero-length email.")
			callback(loginError("Missing email!"))
			return
		}
		
		let headers: HTTPHeaders = [
			"Content-Type": "application/json"
		]
		
		let args: [String: Any] = ["email": email]
		
		Alamofire.request(url, method: .post, parameters:args, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
			guard let httpResponse = response.response else {
				print ("FORGOT PASSWORD ERROR: Could not reach server.")
				callback(loginError("Could not reach the server. Please try again later."))
				return
			}
			printStatus("Forgot password", httpResponse.statusCode)
			
			if 200 ... 299 ~= httpResponse.statusCode  {
				callback(nil)
			} else if 409 == httpResponse.statusCode {
				callback(loginError(l10n("cantSendCode")))
			} else {
				callback(loginError("We have hit an unexpected error. Please try again later!"))
			}
		}
	}
	
	static func resetPassword(code: String, email: String, password: String, callback: @escaping (Error?) -> Void) {
		guard let url = urlWith(path:"users/resetPassword") else {
			print ("RESET PASSWORD: Invalid URL.")
			callback(loginError("Functionality temporarily down."))
			return
		}
		
		guard email.count > 0, code.count > 0, password.count > 0 else {
			print ("RESET PASSWORD: Zero-length data.")
			callback(loginError(l10n("forgotPasswordError")))
			return
		}
		
		let headers: HTTPHeaders = [
			"Content-Type": "application/json"
		]
		
		let args: [String: Any] = ["email": email, "password": password, "resetToken": code.uppercased()]
		
		Alamofire.request(url, method: .post, parameters:args, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
			guard let httpResponse = response.response else {
				print ("RESET PASSWORD ERROR: Could not reach server.")
				callback(loginError("Could not reach the server. Please try again later."))
				return
			}
			printStatus("Reset password", httpResponse.statusCode)
			
			if 200 ... 299 ~= httpResponse.statusCode  {
				callback(nil)
			} else {
				callback(loginError("We have hit an unexpected error. Please try again later!"))
			}
		}
	}
	
	static func resendWelcomeEmail(callback: @escaping (Error?) -> Void) {
		guard let userId = AccountManager.main.user?.userID else {
			callback(loginError("Functionality temporarily down."))
			return
		}
		
		guard let url = urlWith(path:"users/\(userId)/email/resend") else {
			print ("RESET PASSWORD: Invalid URL.")
			callback(loginError("Functionality temporarily down."))
			return
		}
		
		let headers: HTTPHeaders = [
			"Content-Type": "application/json"
		]
		
		Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
			guard let httpResponse = response.response else {
				print ("RESEND EMAIL ERROR: Could not reach server.")
				callback(loginError("Could not reach the server. Please try again later."))
				return
			}
			printStatus("Resend email", httpResponse.statusCode)
			
			if 200 ... 299 ~= httpResponse.statusCode  {
				callback(nil)
			} else {
				callback(loginError("We have hit an unexpected error. Please try again later!"))
			}
		}
	}
	
	
	// MARK: - Private Helpers
	//UNREVIEWED TAG
	static private func checkedStatusForUnreviewed(json: [String: Any]){
		if let userData = json["user"] as? [String: Any] {
			if let unreviewedTableList = userData["unreviewedTables"] as? [[String:Any]] {
				if let unreviewedTableBlock = unreviewedTableList.first {
					if let unreviewedID = unreviewedTableBlock["id"] as? String { //<--- Should call table/{tableID}
						unreviewedTableId = unreviewedID
					}
					if let unreviewedOpen = unreviewedTableBlock["closedAt"] as? String {
						open = !(unreviewedOpen.count > 0)
					}
				}
			}
		}
	}
	
	static private func loginWithFakeUser(callback: @escaping LoginCallback) {
		callback(User.testUser(), nil)
	}
	
	static private func loginError(_ desc: String? = nil, code: Int = 0) -> LoginError {
		let errorDescription = desc ?? l10n("loginGeneric")
		return LoginError.customError(message: errorDescription)
	}

    static func updateUserError(_ desc: String? = nil, code: Int = 0) -> NSError {
        let errorDescription = desc ?? l10n("updateGeneric")
        return NSError(domain: "ca.zemind.rescounts", code: code, userInfo: ["localizedDescription": errorDescription])
    }
}

// MARK: - Error Types

public enum LoginError: Error {
	case customError (message: String?)
}

extension LoginError: LocalizedError {
	public var errorDescription: String? {
		switch self {
		case .customError (message: let message):
			return l10n(message ?? l10n("loginGeneric"))
		}
	}
}
