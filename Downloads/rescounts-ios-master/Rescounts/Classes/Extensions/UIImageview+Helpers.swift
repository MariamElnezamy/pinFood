//
//  UIImageview+Helpers.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2019-05-31.
//  Copyright © 2019 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

extension UIImageView {
	
	func setImageColor(color: UIColor) {
		let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
		self.image = templateImage
		self.tintColor = color
	}
}
