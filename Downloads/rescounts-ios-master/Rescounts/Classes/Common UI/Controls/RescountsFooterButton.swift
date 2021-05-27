//
//  RescountsFooterButton.swift
//  Rescounts
//
//  Created by Kittiphong Xayasane on 2018-08-20.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class RescountsFooterButton: UIButton {

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
		self.setTitleColor(.dark, for: .normal)
		self.titleLabel?.font = UIFont.rescounts(ofSize: 16.0)
		setBackgroundImage(UIImage(color: .gold), for: .normal)
		setBackgroundImage(nil, for: .highlighted)
	}
}
