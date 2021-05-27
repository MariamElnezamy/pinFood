//
//  String+Helpers.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-10.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

extension String {
	func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
		let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
		let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
		
		return ceil(boundingBox.height)
	}
	
	func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
		let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
		let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
		
		return ceil(boundingBox.width)
	}
	
	func titlecased() -> String {
		if self.count <= 1 {
			return self.uppercased()
		}
		
		let regex = try! NSRegularExpression(pattern: "(?=\\S)[A-Z]", options: [])
		let range = NSMakeRange(1, self.count - 1)
		var titlecased = regex.stringByReplacingMatches(in: self, range: range, withTemplate: " $0")
		
		for i in titlecased.indices {
			if i == titlecased.startIndex || titlecased[titlecased.index(before: i)] == " " {
				titlecased.replaceSubrange(i...i, with: String(titlecased[i]).uppercased())
			}
		}
		return titlecased
	}
	
	var trimmed: String {
		return trimmingCharacters(in: .whitespacesAndNewlines)
	}
	
	
	// Dates
	
	// Trims out the fractional seconds part since ISO8601DateFormatter chokes on them
	func trimmedIso8601Format() -> String {
		return replacingOccurrences(of: "\\.\\d+", with: "", options: .regularExpression)
	}
}
