//
//  ClosedRange+Helpers.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-23.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation

extension ClosedRange {
	func clamp(_ value : Bound) -> Bound {
		return self.lowerBound > value ? self.lowerBound
			: self.upperBound < value ? self.upperBound
			: value
	}
}
