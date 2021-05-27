//
//  Unreviewed.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-11-13.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
//UNREVIEWED TAG
class Unreviewed : NSObject {
	public var ID: String? = nil
	public var RestaurantID: String? = nil
	public var RestaurantName: String? = nil
	public var TotalPrice: Int? = nil
	public var Waiter: String? = nil
	public var Tip: Int? = nil
	public var EarnedPoints: Int? = nil
	public var BonusPoints: Int? = nil
	
	public func cleanOut () {
		self.ID = nil
		self.RestaurantID = nil
		self.RestaurantName = nil
		self.Waiter = nil
		self.TotalPrice = nil
		self.EarnedPoints = nil
		self.BonusPoints = nil
		self.Tip = nil
	}
}
