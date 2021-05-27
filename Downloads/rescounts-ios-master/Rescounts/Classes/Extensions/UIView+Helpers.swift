//
//  UIView+Helpers.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-09.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

extension UIView {
	public typealias DrawRectCallback = (UIView, CGRect) -> Void
	public class func withDrawRect(_ drawRect: DrawRectCallback?) -> UIView {
		let v = UIViewWithDrawRect()
		v.callback = drawRect
		return v
	}
	
	public func setX(_ x: CGFloat) {
//		setPosition(x, frame.minY)
		frame.origin.x = x
	}
	
	public func setY(_ y: CGFloat) {
//		setPosition(frame.minX, y)
		frame.origin.y = y
	}
	
	public func setWidth(_ w: CGFloat) {
		setSize(w, frame.height)
	}
	
	public func setHeight(_ h: CGFloat) {
		setSize(frame.width, h)
	}
	
	public func setPosition(_ x: CGFloat, _ y: CGFloat) {
		self.frame = CGRect(origin: CGPoint(x:x, y:y), size: frame.size)
	}
	
	public func setSize(_ w: CGFloat, _ h: CGFloat) {
		self.frame = CGRect(origin: frame.origin, size: CGSize(width:w, height:h))
	}
	
	public func getFirstResponder() -> UIView? {
		for subView in subviews {
			if subView.isFirstResponder {
				return subView
			}
			
			if let recursiveSubView = subView.getFirstResponder() {
				return recursiveSubView
			}
		}
		return nil
	}
	
	public func removeAllSubviews() {
		while (subviews.count > 0) {
			subviews.first?.removeFromSuperview()
		}
	}
}

class UIViewWithDrawRect: UIView {
	public var callback: DrawRectCallback?
	
	override func draw(_ rect: CGRect) {
		callback?(self, rect)
	}
}
extension UINavigationController {
  func popToViewController(ofClass: AnyClass, animated: Bool = true) {
    if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
      popToViewController(vc, animated: animated)
    }
  }
}
