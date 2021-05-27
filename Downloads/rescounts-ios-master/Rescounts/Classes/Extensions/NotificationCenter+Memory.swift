//
//  NotificationCenter+Memory.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2019-07-11.
//  Copyright © 2019 ZeMind Game Studio Ltd. All rights reserved.
//
//	Adapted from https://www.klundberg.com/blog/capturing-objects-weakly-in-instance-method-references-in-swift/
//
//	To use it in class A with a function fooBar() for notification 'notificationName', call it like this:
//		NotificationCenter.default.addMainObserver(forName: .notificationName, owner: self, action: A.fooBar)

import Foundation

extension NotificationCenter {
	open func addMainObserver <T: AnyObject>(forName name: NSNotification.Name?, object obj: Any? = nil, owner: T, action: @escaping (T)->(Notification) -> Void) {
		addObserver(forName: name, object: obj, queue: OperationQueue.main, using: weakify(owner: owner, f: action))
	}
	
	private func weakify <T: AnyObject>(owner: T, f: @escaping (T)->(Notification) -> Void) -> ((Notification) -> Void) {
		return { [weak owner] obj in
			if let owner = owner {
				f(owner)(obj)
			}
		}
	}
}
