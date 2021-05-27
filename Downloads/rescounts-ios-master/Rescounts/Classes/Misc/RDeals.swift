//
//  RDeals.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2019-05-29.
//  Copyright © 2019 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class RDeals: NSObject {
	typealias k = Constants.Menu
	
	
	enum rDealsCharacter: String {
		case rDealsDarkR    = "A"
		case rDealsLightR   = "S"
		case rDealsMagentaR = "D"
	}
	
	
	// MARK: - Public Methods
	
	public static func addIcon(_ icon: rDealsCharacter, size: CGFloat = UIFont.systemFontSize, toText text: String, attrs: [NSAttributedString.Key : Any]? = nil) -> NSAttributedString {
		let retVal = NSMutableAttributedString(string: icon.rawValue, attributes: [.font: UIFont.rDeals(ofSize: size)])
		let restOfText = NSAttributedString(string: text, attributes: attrs)
		retVal.append(restOfText)
		return retVal
	}
	
	public static func title(_ icon: rDealsCharacter, size: CGFloat = UIFont.systemFontSize, attrs: [NSAttributedString.Key : Any]? = nil) -> NSAttributedString {
		return addIcon(icon, size: size, toText: " DEALS", attrs: attrs)
	}
	
	public static func replaceTitleIn(_ text: String, _ icon: rDealsCharacter, size: CGFloat = UIFont.systemFontSize, titleAttrs: [NSAttributedString.Key : Any]? = nil, otherAttrs: [NSAttributedString.Key : Any]? = nil) -> NSAttributedString {
		let retVal = NSMutableAttributedString(string: text, attributes: otherAttrs)
		
		// Check if we even have a title to replace
		let range  = (text.lowercased() as NSString).range(of: k.rDealsName.lowercased())
		guard range.location != NSNotFound else {
			return retVal
		}
		
		// We have a title, so replace it with the icon version
		let titleText = title(icon, size: size, attrs: titleAttrs)
		retVal.replaceCharacters(in: range, with: titleText)
		
		return retVal
		
	}
}
