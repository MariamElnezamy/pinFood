//
//  ProgressBar.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-08-06.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class ProgressBar: UIControl {

	private let bar = UIView()
	public var constantCornerRadius: CGFloat? = nil
	
	public var percent: CGFloat = 0 {
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
		self.backgroundColor = .white
		self.layer.masksToBounds = true
		
		setupBar()
		update()
	}
	
	
	// MARK: - UIView Methods
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		layer.cornerRadius = constantCornerRadius ?? frame.height / 2
		bar.layer.cornerRadius = constantCornerRadius ?? frame.height / 2
		
		bar.frame = CGRect(0, 0, frame.width * percent, frame.height)
	}
	
	// MARK: - Private Methods
	
	private func setupBar() {
		bar.backgroundColor = .gold
		bar.isUserInteractionEnabled = false
		addSubview(bar)
	}
	
	private func update() {
		setNeedsLayout()
	}

}
