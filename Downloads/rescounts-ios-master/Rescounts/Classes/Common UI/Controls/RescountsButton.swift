//
//  RescountsButton.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-08-05.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class RescountsButton: UIButton {
	
	enum DisplayType {
		case primary
		case secondary
	}
	
	public var displayType: DisplayType = .primary {
		didSet { update() }
	}
	
	
	// MARK: - Initialization
	
	convenience init() {
		self.init(frame: .arbitrary)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		self.backgroundColor = .clear
		self.layer.cornerRadius = 13
		self.layer.masksToBounds = true
		self.layer.borderColor = UIColor.gold.cgColor
		self.layer.borderWidth = 3
		self.setTitleColor(.dark, for: .normal)
		
		update()
	}
	
	
	// MARK: - Private Helpers
	
	private func update() {
		if (displayType == .primary) {
			setBackgroundImage(UIImage(color: .gold), for: .normal)
			setBackgroundImage(nil, for: .highlighted)
		} else {
			setBackgroundImage(UIImage(color: .white), for: .normal)
			setBackgroundImage(UIImage(color: .lightGray), for: .highlighted)
		}
	}
}
