//
//  RescountsTextField.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-03.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class RescountsTextField: UITextField {
	
	public var textInset: CGFloat = 10.0
	public var showSearchIcon: Bool = false {
		didSet { updateSearchIcon() }
	}
	private let searchIcon = UIImageView(image:UIImage(named: "IconSearch"))
	private let cancelButton = UIButton()
	
	let kIconSize: CGFloat = 20
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		setupCancelButton()
	}
	
	private func setupCancelButton() {
		let cancelIcon = UIImage(named: "iconCancel")?.withRenderingMode(.alwaysTemplate)
		cancelButton.setImage(cancelIcon, for: .normal)
		cancelButton.imageView?.tintColor = .dark
	}
	
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		return bounds.insetBy(dx: textInset, dy: 0.0)
	}
	
	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		return textRect(forBounds: bounds)
	}
	
	override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		var retVal = textRect(forBounds: bounds)
		if showSearchIcon {
			let halfSize = floor(kIconSize / 2) + 2
			retVal = retVal.insetBy(dx: halfSize).offsetBy(dx: halfSize) // Insets just the left side by (iconSize + 4)
		}
		return retVal
	}
	
	override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
		return CGRect(textInset, 0, kIconSize, bounds.height)
	}
	
	override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
		return CGRect(bounds.width - textInset - kIconSize, 0, kIconSize, bounds.height)
	}
	
	public func showCancelButton(_ callback: @escaping ()->()) {
		if (text ?? "").count > 0 {
			rightView = cancelButton
			rightViewMode = .unlessEditing
			
			cancelButton.addAction(for: .touchUpInside) { [weak self] in
				self?.rightView = nil
				self?.text = nil
				self?.updateSearchIcon()
				callback()
			}
		}
	}
	
	public func updateSearchIcon() {
		let view: UIImageView? = (showSearchIcon && (text ?? "").count == 0) ? searchIcon : nil
		view?.contentMode = .scaleAspectFit
		
		leftView = view
		leftViewMode = .unlessEditing
		
		setNeedsLayout()
	}
}
