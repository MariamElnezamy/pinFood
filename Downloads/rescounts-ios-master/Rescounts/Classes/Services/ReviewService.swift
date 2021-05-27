//
//  ReviewService.swift
//  Rescounts
//
//  Created by Kit Xayasane on 2018-08-25.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import Alamofire

class ReviewService: BaseService {
	typealias deleteCallback = (Error?) -> Void
    typealias ReviewCallback = (String?, Error?) -> Void
	typealias FetchCallback = ([RestaurantReview]?) -> Void
	
	public static var shouldICall: Bool = true
	
	static func shouldIMakeCall() -> Bool {
		return shouldICall
	}
	
	static let kMaxImageDimension:CGFloat = 1200
    
    static func submitReview(review: Review, callback: @escaping ReviewCallback) {
        if useTestData() {
            review.user = User.testUser()
        }
        
        guard let url = urlWith(path:"tables/\(review.tableID)/review") else {
            print ("ERROR SUBMITTING REVIEW: Invalid URL.")
            callback(nil, NSError(domain: "ca.zemind.rescounts", code: 0, userInfo: ["localizedDescription": "Invalid URL"]))
            return
        }
		
        var args: [String: Any] = ["rating": review.restaurantRating,
								   "serverRating": review.serverRating]
		if let reviewText = review.reviewText {
			args["text"] = reviewText
		}
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
			"Authorization": AccountManager.main.tokenArg
        ]
        
        Alamofire.request(url, method: .post, parameters: args, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            guard let httpResponse = response.response else {
                print ("ERROR SUBMITTING REVIEW: Could not reach server.")
                callback(nil, submitReviewError(l10n("couldNotReachServer")))
                return
            }
            printStatus("Submit Review", httpResponse.statusCode)
            
            guard let json = response.result.value as? [String: Any] else {
                print ("ERROR SUBMITTING REVIEW: Invalid JSON.")
                callback(nil, submitReviewError())
                return
            }
			
			guard let id = json["id"] as? String else {
				callback(nil, submitReviewError())
				return
			}
			
			if let earnedPoints = json["earnedPoints"] as? Int {
				OrderManager.main.unreviewedTable.EarnedPoints = earnedPoints
			}
			if let bonusPoints = json["bonusPoints"] as? Int {
				OrderManager.main.unreviewedTable.BonusPoints = bonusPoints
			}
			
            callback(id, nil)
        }
        
        func submitReviewError(_ desc: String? = nil, code: Int = 0) -> NSError {
            let errorDescription = desc ?? l10n("reviewGeneric")
            return NSError(domain: "ca.zemind.rescounts", code: code, userInfo: ["localizedDescription": errorDescription])
        }
    }
	
	static func uploadReviewImage(reviewId: String?, reviewImage: UIImage, callback: @escaping ReviewCallback) {

		guard let url = urlWith(path:"reviews/\(reviewId ?? "")/photo") else {
			print ("SET PROFILE PICTURE: Invalid URL.")
			callback(nil, ReviewService().submitReviewPhotoError("Invalid URL."))
			return
		}
		
		guard let uploadImage = resizeImageIfNecessary(image: reviewImage) else {
			return
		}
		
		let headers: HTTPHeaders = [
			"Content-Type": "image/jpeg",
			"Authorization": AccountManager.main.tokenArg
		]
		
		if let imageData = UIImageJPEGRepresentation(uploadImage, 0.1) {
			Alamofire.upload(imageData, to: url, method: .post, headers: headers).responseJSON { response in
				guard let httpResponse = response.response else {
					print ("SET PROFILE PICTURE: Could not reach server.")
					callback(nil, ReviewService().submitReviewPhotoError(l10n("couldNotReachServer")))
					return
				}
				printStatus("SET PROFILE PICTURE", httpResponse.statusCode)
				
				guard let json = response.result.value as? [String: Any] else {
					print ("ERROR SUBMITTING REVIEW: Invalid JSON.")
					callback(nil, ReviewService().submitReviewPhotoError())
					return
				}
				
				guard let id = json["id"] as? String else {
					callback(nil, ReviewService().submitReviewPhotoError())
					return
				}
				
				callback(id, nil)
			}
		}
	}
	
	static func resizeImageIfNecessary(image: UIImage) -> UIImage? {
		
		if (image.size.width < kMaxImageDimension && image.size.height < kMaxImageDimension) {
			return image
		}
		
		if (image.size.width > image.size.height) {

			let scaleFactor:CGFloat = kMaxImageDimension / image.size.width;
			
			let newHeight:CGFloat = image.size.height * scaleFactor;
			let newWidth:CGFloat = image.size.width * scaleFactor;
						return resizeImage(image: image, newWidth: newWidth, newHeight: newHeight)
		} else {
			let scaleFactor:CGFloat = kMaxImageDimension / image.size.height;
			
			let newHeight:CGFloat = image.size.height * scaleFactor;
			let newWidth:CGFloat = image.size.width * scaleFactor;
			return resizeImage(image: image, newWidth: newWidth, newHeight: newHeight)
		}
	}
	
	static func resizeImage(image: UIImage, newWidth:CGFloat, newHeight:CGFloat) ->UIImage? {
		let newSize: CGSize = CGSize(width: newWidth, height: newHeight)

		// This is the rect that we've calculated out and this is what is actually used below
		let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
		
		// Actually do the resizing to the rect using the ImageContext stuff
		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
		image.draw(in: rect)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return newImage
	}
	
	func submitReviewPhotoError(_ desc: String? = nil, code: Int = 0) -> NSError {
		let errorDescription = desc ?? l10n("submitPhotoGeneric")
		return NSError(domain: "ca.zemind.rescounts", code: code, userInfo: ["localizedDescription": errorDescription])
	}
	
	static func deleteReview(review: RestaurantReview, callback: @escaping deleteCallback) {
	
		guard let url = urlWith(path:"reviews/\(review.reviewID)") else {
			print ("ERROR DELETING REVIEW: Invalid URL.")
			callback(NSError(domain: "ca.zemind.rescounts", code: 0, userInfo: ["localizedDescription": "Invalid URL"]))
			return
		}
		
		let headers: HTTPHeaders = [
			"Content-Type": "application/json",
			"Authorization": AccountManager.main.tokenArg
		]
		
		Alamofire.request(url, method: .delete, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
			guard let httpResponse = response.response else {
				print ("ERROR DELETING REVIEW: Could not reach server.")
				callback( deleteReviewError(l10n("couldNotReachServer")))
				return
			}
			printStatus("Delete Review", httpResponse.statusCode)
			
			
			if 200 ... 299 ~= httpResponse.statusCode  {
				callback(nil)
			} else {
				callback(deleteReviewError())
			}
			
		}
		
		func deleteReviewError(_ desc: String? = nil, code: Int = 0) -> NSError {
			let errorDescription = desc ?? l10n("deletePhotoGeneric")
			return NSError(domain: "ca.zemind.rescounts", code: code, userInfo: ["localizedDescription": errorDescription])
		}
	}
	
	//TODO: REVIEWS
	static func fetchReviews(restaurant: Restaurant?, offset: Int = 0,  callback: @escaping FetchCallback) {
		guard let restaurantID = restaurant?.restaurantID, restaurantID.count > 0 else {
			print("FETCH ERROR: Missing restaurant ID.")
			callback(nil)
			return
		}
		
		guard let url = urlWith(path: "restaurants/\(restaurantID)/reviews") else {
			print("FETCH ERROR: Invalid URL.")
			callback(nil)
			return
		}
		
		let args : [String: Any] = ["limit" : 10,
									"offset": offset]
		ReviewService.shouldICall = false
		Alamofire.request(url, parameters: args).responseJSON{ response in
			ReviewService.shouldICall = true
			printStatus("Fetch", response.response?.statusCode)
			
			guard let json = response.result.value as? [String: Any] else {
				print ("FETCH ERROR: Invalid JSON")
				callback(nil)
				return
			}
			
			var results: [RestaurantReview] = []
			(json["reviews"] as? [[String: Any]])?.forEach {
				if let review = RestaurantReview(json: $0, fromRestaurant: restaurant?.name) {
					results.append(review)
				}
			}
			
			callback(results)
		}
	}
}
