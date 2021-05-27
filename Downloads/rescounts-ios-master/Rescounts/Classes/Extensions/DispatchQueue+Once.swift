//
//  DispatchQueue+Once.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-08-06.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//
//	Adapted from:
//		https://stackoverflow.com/questions/37886994/dispatch-once-after-the-swift-3-gcd-api-changes

import Foundation

public extension DispatchQueue {
	
	private static var _onceTracker = [String]()
	
	/**
	Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
	only execute the code once even in the presence of multithreaded calls.
	
	- parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
	- parameter block: Block to execute once
	*/
	class func once(token: String, block: ()->Void) {
		objc_sync_enter(self); defer { objc_sync_exit(self) }
		
		if _onceTracker.contains(token) {
			return
		}
		
		_onceTracker.append(token)
		block()
	}
	
	class func clearOnceToken(_ token: String) {
		if let index = _onceTracker.index(of:token) {
			_onceTracker.remove(at: index)
		}
	}
}

