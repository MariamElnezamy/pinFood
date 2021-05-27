//
//  ProfileRewardItem.swift
//  Rescounts
//
//  Created by Kittiphong Xayasane on 2018-08-14.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class ProfileRewardItem: NSObject {
	var title: String = ""
	var iconName: String = ""
	var amount: Int = 0
	
	
	// MARK: - Initialization
	
	init(id title: String, iconName: String, amount: Int) {
		self.title = title
		self.iconName = iconName
		self.amount = amount
		
		super.init()
	}
}
