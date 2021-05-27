//
//  FullScreenSpinner.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-08-22.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class FullScreenSpinner: UIView {
	
	public let spinner = CircularLoadingSpinner()
	
	private let kSpinnerSize: CGFloat = 60

	
	// MARK: - Public Methods
	
	@discardableResult
	public static func show() -> FullScreenSpinner {
		let v = FullScreenSpinner()
		if let parent = UIApplication.shared.keyWindow {
			let v = FullScreenSpinner()
			v.frame = parent.bounds
			parent.addSubview(v)
		}
		return v
	}
	
	public static func hideAll() {
		let subviews = UIApplication.shared.keyWindow?.subviews ?? []
		for v in subviews {
			if let v = v as? FullScreenSpinner {
				v.hide()
			}
		}
	}
	
	public func hide() {
		removeFromSuperview()
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
		self.backgroundColor = UIColor(white: 0, alpha: 0.5)
		self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		addSubview(spinner)
	}
	
	
	// MARK: - UIView methods
	override func layoutSubviews() {
		super.layoutSubviews()
		
		spinner.frame = CGRect(floor(0.5 * (frame.width - kSpinnerSize)), floor(0.5 * (frame.height - kSpinnerSize)), kSpinnerSize, kSpinnerSize)
	}
	
}
