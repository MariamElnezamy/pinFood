//
//  Dictionary+Subscript.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2017-08-03.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//
//	Taken from: https://stackoverflow.com/questions/40261857/remove-nested-key-from-dictionary
//	Allows access nested [String:Any] dicts like this:
//		dict[jsonDict: "countries"]?[jsonDict: "japan"]?[jsonDict: "capital"]?["name"] = "berlin"

import Foundation

extension Dictionary {
	subscript(jsonDict key: Key) -> [String:Any]? {
		get {
			return self[key] as? [String:Any]
		}
		set {
			self[key] = newValue as? Value
		}
	}
}
