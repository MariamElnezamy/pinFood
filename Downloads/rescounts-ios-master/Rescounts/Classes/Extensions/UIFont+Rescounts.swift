//
//  UIFont+Rescounts.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-19.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

extension UIFont {
	public static func rescounts(ofSize size: CGFloat) -> UIFont {
		return UIFont(name: "Montserrat-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
	}
	
	public static func lightRescounts(ofSize size: CGFloat) -> UIFont {
		return UIFont(name: "Montserrat-Light", size: size) ?? UIFont.systemFont(ofSize: size)
	}
	
	public static func semiBoldRescounts(ofSize size: CGFloat) -> UIFont {
		return UIFont(name: "Montserrat-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size)
	}
	
	public static func boldRescounts(ofSize size: CGFloat) -> UIFont {
		return UIFont(name: "Montserrat-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
	}
	
	public static func rDeals(ofSize size: CGFloat) -> UIFont {
		return UIFont(name: "RDealsv1Regular", size: size) ?? UIFont.systemFont(ofSize: size)
	}
	
	public static func printFonts() {
		for fontFam in UIFont.familyNames {
			print("\(fontFam):")
			for name in UIFont.fontNames(forFamilyName: fontFam) {
				print("\t  \(name)")
			}
		}
	}
	
	public var aboveCapHeight: CGFloat {
		return ascender - capHeight
	}
	
	// As defined by http://www.cyrilchandelier.com/understanding-fonts-and-uifont
	public var lineGapHeight: CGFloat {
		return lineHeight - ascender + descender
	}
	
	public func topCapYForLabelHeight(_ labelHeight: CGFloat) -> CGFloat {
		return (labelHeight - lineHeight) / 2 + aboveCapHeight
	}
}
