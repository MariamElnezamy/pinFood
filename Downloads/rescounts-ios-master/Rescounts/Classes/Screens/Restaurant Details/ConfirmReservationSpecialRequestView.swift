//
//  ConfirmReservationSpecialRequestView.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-08-22.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import UIKit

class ConfirmReservationSpecialRequestView : UIView, UITextViewDelegate {
	private let title = UILabel()
	private let mainTextView = UITextView()
	private let textViewHeight : CGFloat = 100
	private let tapCatchingView = UIView()
	private let separator1 = UIView()
	private let separator2 = UIView()
	
	private let spacer : CGFloat = 7
	
	private let kPlaceholderText = l10n("specialRequestsTxt")
	
	
	// MARK: Initialization
	
	override init(frame: CGRect){
		super.init(frame: frame)
		commonInit()
		
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	private func commonInit() {
		title.text = l10n("specialRequests").uppercased()
		title.font = UIFont.lightRescounts(ofSize: 16)
		title.textColor = UIColor.highlightRed
		mainTextView.font = UIFont.lightRescounts(ofSize: 13)
		mainTextView.delegate = self
		mainTextView.text = kPlaceholderText
		mainTextView.textColor = .gray
		separator1.backgroundColor = UIColor.separators
		separator2.backgroundColor = UIColor.separators
		
		addSubview(title)
		addSubview(mainTextView)
		addSubview(separator1)
		addSubview(separator2)
		
		setupKeyboardDismissView()
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		
	}
	
	
	// MARK : - UITextView setup
	private func setupKeyboardDismissView() {
		tapCatchingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
		tapCatchingView.addGestureRecognizer(tap)
	}
	
	@objc func dismissKeyboard(){
		(self.superview ?? self).endEditing(true)
	}
	
	@objc func keyboardWillShow(notification:  NSNotification){
		if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
			self.superview?.frame.origin.y = -keyboardSize.height
		}
		tapCatchingView.frame = self.superview?.bounds ?? CGRect(0,0,self.frame.width, self.frame.height)
		self.superview?.addSubview(tapCatchingView)
	}
	
	@objc func keyboardWillHide(notification: NSNotification){
		self.superview?.frame.origin.y = 0
		tapCatchingView.removeFromSuperview()
	}
	
	
	// MARK : - layout frame
	
	private func setupFrames () {
		title.frame  = CGRect(Constants.Order.leftMargin, Constants.Order.cellPaddingTop - spacer, self.frame.width, Constants.Order.textHeight)
		mainTextView.frame = CGRect(Constants.Order.leftMargin, title.frame.maxY, self.frame.width - Constants.Order.leftMargin * 2, textViewHeight)
		separator1.frame = CGRect(0, 0, self.frame.width, Constants.Menu.separatorHeight)
		separator2.frame = CGRect(0, mainTextView.frame.maxY - Constants.Menu.separatorHeight, self.frame.width, Constants.Menu.separatorHeight)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		setupFrames()
	}
	
	
	// MARK: - public funcs
	
	public func getIdealHeight() -> CGFloat {
		return Constants.Order.cellPaddingTop - spacer + Constants.Order.textHeight + textViewHeight + 10
	}
	
	public func getText() -> String? {
		return (mainTextView.text != kPlaceholderText) ? mainTextView.text : nil
	}
	
	
	// MARK: - UITextViewDelegate
	
	public func textViewDidBeginEditing(_ textView: UITextView) {
		if (textView.text == kPlaceholderText) {
			textView.text = nil
			textView.textColor = .black
		}
	}
	
	public func textViewDidEndEditing(_ textView: UITextView) {
		if ((textView.text ?? "") == "") {
			textView.text = kPlaceholderText
			textView.textColor = .gray
		}
	}
}
