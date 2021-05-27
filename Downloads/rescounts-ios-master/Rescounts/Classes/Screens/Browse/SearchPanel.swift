//
//  SearchPanel.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-03.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

protocol SearchPanelDelegate: class {
	func performSearch(_ text: String?) // called when 'search' key pressed
}


class SearchPanel: UIView, UITextFieldDelegate {
	
	public var leftMargin: CGFloat = 0.0 {
		didSet { setNeedsLayout() }
	}
	
	weak public var searchDelegate: SearchPanelDelegate?
	public private(set) var textField = RescountsTextField()
	
	public var checkGroup = CheckBoxGroup()
	
	public static let kBarHeight: CGFloat = 50.0 + 40.0 // for the checkbox
	private let kTopMargin: CGFloat = 10.0
	private let kBottomMargin: CGFloat = 10.0
	private let kRightMargin: CGFloat = 8.0
	
	
	// MARK: - Initialization
	
	convenience init(leftMargin: CGFloat = 8.0) {
		self.init(frame: CGRect(0, 0, 200, 100), leftMargin: leftMargin) // Arbitrary rect for autoresizing
	}
	
	init(frame: CGRect, leftMargin lMargin: CGFloat) {
		leftMargin = lMargin
		
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		addSubview(textField)
		
		textField.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
		textField.placeholder = l10n("search").titlecased()
		textField.textInset = 10.0
		textField.returnKeyType = .search
		textField.clearButtonMode = .whileEditing
		textField.delegate = self
		
		checkGroup.backgroundColor = UIColor.dark
		addSubview(checkGroup)
		
		self.backgroundColor = UIColor.dark
		self.layer.borderWidth = 0.5
		self.layer.borderColor = UIColor(white: 0.7, alpha: 1.0).cgColor
	}
	
	
	// MARK: - Public Methods
	
	public static func showInView(_ view: UIView, atY y: CGFloat, leftMargin: CGFloat, delegate: SearchPanelDelegate? = nil, setup: ((SearchPanel) -> Swift.Void)? = nil) -> SearchPanel {
		let panel = SearchPanel(frame: CGRect(-1, y - kBarHeight - 1, view.frame.width + 2, kBarHeight), leftMargin: leftMargin)
		view.addSubview(panel)
		panel.searchDelegate = delegate
		
		setup?(panel) // Allow the caller to do additional setup before presenting it
		
		panel.show()
		
		return panel
	}
	
	public func show() {
		self.moveBy(self.frame.height)
		self.textField.becomeFirstResponder()
	}
	
	public func hide() {
		self.moveBy(-self.frame.height) { (_ finished: Bool) in
			self.removeFromSuperview()
		}
		self.textField.resignFirstResponder()
	}
	
	
	// MARK: - Private Helpers
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let textFieldHeight : CGFloat = 55.0 - kTopMargin - kBottomMargin
		textField.frame = CGRect(leftMargin, kTopMargin, frame.width - 2 * leftMargin, textFieldHeight)
		
		let checkGroupPadding : CGFloat =  SearchPanel.kBarHeight/2.0 - textField.frame.maxY/2.0 - checkGroup.idealHeight()/2.0
		checkGroup.frame = CGRect(leftMargin, textField.frame.maxY + checkGroupPadding, frame.width - 2 * leftMargin, checkGroup.idealHeight())
	}
	
	private func moveBy(_ dY: CGFloat, completion: ((Bool) -> Swift.Void)? = nil) {
		
		UIView.animate(withDuration: 0.2, animations: {
			self.frame = self.frame.offsetBy(dx: 0, dy: dY)
		}) { (_ finished: Bool) in
			completion?(finished)
		}
	}
	
	
	// MARK: - UITextField Delegate
	
	public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		searchDelegate?.performSearch(textField.text)
		return true
	}

}
