//
//  UIButton+Helpers.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-09-13.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

extension UIButton {
	
	func applyAttributes(_ attrs: [NSAttributedStringKey: Any], toSubstring str: String? = nil) {
		if let rawText = title(for: .normal) {
			let attrText = NSMutableAttributedString(string:rawText, attributes:[.foregroundColor: titleColor(for: .normal) ?? UIColor.black])
			
			if let str = str, let range = rawText.range(of: str) {
				attrText.addAttributes(attrs, range: NSRange(range, in:str))
			} else {
				attrText.addAttributes(attrs, range: NSMakeRange(0, rawText.count))
			}
			setAttributedTitle(attrText, for: .normal)
		}
	}
}
