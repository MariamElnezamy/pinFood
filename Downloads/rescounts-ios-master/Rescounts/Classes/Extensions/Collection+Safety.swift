//
//  Collection+Safety.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-09.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation

extension Collection {
	
	/// Returns the element at the specified index iff it is within bounds, otherwise nil.
	subscript (safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}

