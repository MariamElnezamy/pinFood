//
//  Array+Helpers.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-08-18.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
	func difference(from other: [Element]) -> [Element] {
		let thisSet = Set(self)
		let otherSet = Set(other)
		return Array(thisSet.symmetricDifference(otherSet))
	}
}
