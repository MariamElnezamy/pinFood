//
//  UIControl+Closure.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-09.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//
//	Adds ability to set closures as callbacks for UIControl events
//
//	Adapted from:
//	 - https://stackoverflow.com/questions/25919472/adding-a-closure-as-target-to-a-uibutton
//
//	Usage:
//		self.button.addAction(for: .touchUpInside) { [weak self] in
//			self?.doStuff()
//		}

import UIKit

class ClosureSleeve {
	let closure: ()->()
	
	init (_ closure: @escaping ()->()) {
		self.closure = closure
	}
	
	@objc func invoke () {
		closure()
	}
}

extension UIControl {
	func addAction(for controlEvents: UIControlEvents, _ closure: @escaping ()->()) {
		let sleeve = ClosureSleeve(closure)
		addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
		objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
	}
}
