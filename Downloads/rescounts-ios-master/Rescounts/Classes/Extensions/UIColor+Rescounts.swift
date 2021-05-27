//
//  UIColor+Rescounts.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-19.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

extension UIColor {
	public class var primary: UIColor {
		return UIColor(red: 0.831, green: 0.165, blue: 0.349, alpha: 1)
	}
	
	public class var gold: UIColor {
		return UIColor(red:0.910, green:0.812, blue:0.137, alpha:1)
	}
	
	public class var dark: UIColor {
		return UIColor(red:0.278, green:0.278, blue:0.275, alpha:1)
	}
    
    public class var lighterGray: UIColor {
        return UIColor(red:0.953, green:0.949, blue:0.941, alpha:1)
    }
    
	
	public class var nearBlack: UIColor {
		return UIColor(red:0.15, green:0.15, blue:0.15, alpha:1)
	}
	
	public class var lightGrayText: UIColor {
		return UIColor(red:0.75, green:0.75, blue:0.75, alpha:1)
	}
	
	public class var separators: UIColor {
		return UIColor(red:0.75, green:0.75, blue:0.75, alpha:1)
	}
	
	public class var openGreen: UIColor {
		return UIColor(red:0.32, green:0.72, blue:0.28, alpha:1)
	}
	
	public class var closedRed: UIColor {
		return UIColor(red:0.75, green:0, blue:0, alpha:1)
	}
	
	public class var dimmedBackground: UIColor {
		return UIColor(white: 0, alpha: 0.6)
	}
	
	public class var random: UIColor {
		return UIColor(red: CGFloat.random, green: CGFloat.random, blue: CGFloat.random, alpha:1)
	}
	
	public class var highlightRed : UIColor {
		return UIColor(red: 0.83, green: 0.16, blue: 0.35, alpha: 1)
	}
	
	public func darker() -> UIColor {
		var r : CGFloat = 0; var g : CGFloat = 0; var b : CGFloat = 0; var a: CGFloat = 0
		
		if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
			return UIColor(red: r*0.8, green: g*0.8, blue: b*0.8, alpha: a)
		} else {
			return self
		}
	}
	
	public func withAlpha(_ alpha: CGFloat) -> UIColor {
		var r : CGFloat = 0; var g : CGFloat = 0; var b : CGFloat = 0; var a: CGFloat = 0
		
		if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
			return UIColor(red: r, green: g, blue: b, alpha: alpha)
		} else {
			return self
		}
	}
	
	public func lighter() -> UIColor {
		var r : CGFloat = 0; var g : CGFloat = 0; var b : CGFloat = 0; var a: CGFloat = 0
		
		if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
			return UIColor(red: 0.2 + r*0.8, green: 0.2 + g*0.8, blue: 0.2 + b*0.8, alpha: a)
		} else {
			return self
		}
	}
	
	public var getAlpha: CGFloat {
		var r : CGFloat = 0; var g : CGFloat = 0; var b : CGFloat = 0; var a: CGFloat = 0
		
		if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
			return a
		} else {
			return 1
		}
	}
}
