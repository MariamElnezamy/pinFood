//
//  BaseService.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-15.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit
import Alamofire

class BaseService: NSObject {
	typealias RescountsServiceCallback = (_ success: Bool) -> Void
	
	internal static var kHostName = "https://api.rescounts.com/"
	internal static let kBasePath = "api/v1/"
	
	internal static func urlWith(path: String) -> URL? {
		return URL(string: "\(kHostName)\(kBasePath)")?.appendingPathComponent(path)
	}
	
	internal static func useTestData() -> Bool {
		if (Constants.Debug.useTestData) { Helper.assertTestBuild() }
		return Constants.Debug.useTestData
	}
	
	internal static func printStatus(_ service: String, _ statusCode: Int?) {
		if let status = statusCode {
			switch(status) {
			case 200...299:
				print("\(service) success: \(status)")
			default:
				print("ERROR with \(service) response: \(status)")
			}
		}
	}
	
	override init() {
		let config = URLSessionConfiguration.default
		config.requestCachePolicy = .reloadIgnoringLocalCacheData
		config.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
		config.urlCache = nil
		//		let manager : SessionManager = SessionManager(configuration: config)
		let manager = Alamofire.SessionManager(configuration: config)
		let delegate: Alamofire.SessionDelegate = manager.delegate
		//delegate.dataTaskWillCacheResponse
		//Overriding delegate to add headers
		delegate.dataTaskWillCacheResponseWithCompletion = { session, datatask, cachedResponse, completion in
			let response = cachedResponse.response  as! HTTPURLResponse
			var headers = response.allHeaderFields as! [String: String]
			print(headers.keys.contains("Cache-Control"))
			headers["Cache-Control"] = "max-age=30"
			let modifiedResponse = HTTPURLResponse(
				url: response.url!,
				statusCode: response.statusCode,
				httpVersion: "HTTP/1.1",
				headerFields: headers)
			
			let modifiedCachedResponse = CachedURLResponse(
				response: modifiedResponse!,
				data: cachedResponse.data,
				userInfo: cachedResponse.userInfo,
				storagePolicy: cachedResponse.storagePolicy)
			completion(modifiedCachedResponse)
		}
	}
}
