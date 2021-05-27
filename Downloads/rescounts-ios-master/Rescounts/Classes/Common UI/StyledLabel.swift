//
//  StyledLabel.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2019-06-11.
//  Copyright © 2019 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class StyledLabel: UILabel {
	
	private var strikeView: UIView?
	
	private let kStrikeHeight: CGFloat = 1
	
	
	// MARK: - Public Methods
	
	public func applyStrikeThrough(_ isOn: Bool) {
		if (isOn) {
			addStrikethrough()
		} else {
			removeStrikethrough()
		}
	}
	
	public func addStrikethrough() {
		if strikeView == nil {
			createStrikeView()
		}
		
		updateStrikeThrough()
	}
	
	public func removeStrikethrough() {
		strikeView?.removeFromSuperview()
		strikeView = nil
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		strikeView?.frame = CGRect(0, floor((frame.height - kStrikeHeight) / 2), frame.width, kStrikeHeight)
	}
	
	
	// MARK: - Private Helpers
	
//	private var strikeView: UIView? {
//		for v in subviews {
//			if v.tag == UILabel.kStrikeThroughTag { // Not using viewWithTag() because we only want direct children
//				return v
//			}
//		}
//		return nil
//	}
	
	private func createStrikeView() {
		let v = UIView()
		
		addSubview(v)
//		v.autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleBottomMargin]
		
		strikeView = v
	}
	
	private func updateStrikeThrough(_ v: UIView? = nil) {
		// Update label-dependent properties
		strikeView?.backgroundColor = textColor
	}
}
