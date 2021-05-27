//
//  ProfileItem.swift
//  Rescounts
//
//  Created by Kittiphong Xayasane on 2018-08-13.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class ProfileItem: NSObject {
	var title: String = ""
	var iconName: String = ""
	var action: String = ""
	var identifier: String = ""
	
	
	// MARK: - Initialization
	
	init(title: String, iconName: String, action: String, identifier: String? = nil) {
		self.title = title
		self.iconName = iconName
		self.action = action
		self.identifier = identifier ?? title
		
		super.init()
	}
	
}
