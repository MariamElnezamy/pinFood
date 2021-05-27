//
//  Date+Helpers.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-11.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation

extension Date {
	func isBetween(_ date1: Date, _ date2: Date) -> Bool {
		return (min(date1, date2) ... max(date1, date2)).contains(self)
	}
	
	public func round(precision: TimeInterval) -> Date {
		return round(precision: precision, rule: .toNearestOrAwayFromZero)
	}
	
	public func ceil(precision: TimeInterval) -> Date {
		return round(precision: precision, rule: .up)
	}
	
	public func floor(precision: TimeInterval) -> Date {
		return round(precision: precision, rule: .down)
	}
	
	public func adding(minutes: Int) -> Date {
		if let result = Calendar.current.date(byAdding: .minute, value: minutes, to: self) {
			return result
		}
		return Date()
	}
	
	private func round(precision: TimeInterval, rule: FloatingPointRoundingRule) -> Date {
		let seconds = (self.timeIntervalSinceReferenceDate / precision).rounded(rule) *  precision;
		return Date(timeIntervalSinceReferenceDate: seconds)
	}
}
