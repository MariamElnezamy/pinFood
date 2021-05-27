//
//  MyAccountTableViewCell.swift
//  Rescounts
//
//  Created by Kittiphong Xayasane on 2018-08-15.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class MyAccountTableViewCell: UITableViewCell, UITextFieldDelegate {
	
    public var doneEditingCallback: ((String) -> Void)? = nil
	public var data: MyAccountItem? {
		didSet { prepareForDisplay() }
	}
	
	static let paddingSide: CGFloat = 25
	static let separatorHeight: CGFloat = 2
	static let paddingTop: CGFloat = 14
	static let lineHeight: CGFloat = 20
	
	private let titleLabel = UILabel()
	private let textField = UITextField()
	private let separator    = UIView()
	
	
	// MARK: - Initialization
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		commonInit()
	}
	
	private func commonInit() {
		addSubview(titleLabel)
        textField.delegate = self
		addSubview(textField)
		addSubview(separator)
	}
	
	
	// MARK: - Public Methods
	public class func height(_ accountItem: MyAccountItem, width cellWidth: CGFloat) -> CGFloat {
		return 2 * paddingTop + heightForText(accountItem.title, width: cellWidth, indent: 0) + separatorHeight
	}
	
	public func prepareForDisplay() {
		setupLabel(titleLabel,      font: .lightRescounts(ofSize: 15), text: data?.title, colour: .primary)
		titleLabel.text = data?.title
		
		textField.textAlignment = .right
		
		if data?.valueType == .password {
			textField.placeholder = l10n("entNewPass")
			textField.isSecureTextEntry = true;
			textField.font = .lightRescounts(ofSize: 15)
		} else if data?.valueType == .phoneNumber {
			textField.text = data?.value
			textField.keyboardType = .numberPad
			textField.font = .rescounts(ofSize: 15)
		} else if data?.valueType == .birthday {
			textField.text = data?.value
			data?.date = AccountManager.main.user?.birthday
			let datePickerView = UIDatePicker()
			datePickerView.datePickerMode = .date
			textField.inputView = datePickerView
			textField.font = .rescounts(ofSize: 15)
			datePickerView.addTarget(self, action: #selector(getDateString(sender:)), for: .valueChanged)
		}
		else {
			textField.text = data?.value
			textField.font = .rescounts(ofSize: 15)
		}
		separator.backgroundColor = .separators
	}
	
	
	// MARK: - Private Helpers
	
	@objc func getDateString(sender: UIDatePicker){
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM-dd-yyyy"
		let realDate = sender.date
		data?.date = realDate
		self.textField.text = dateFormatter.string(from: sender.date)
	}
	
	private class func heightForText(_ text: String, width cellWidth: CGFloat, indent: CGFloat = 0) -> CGFloat{
		let textWidth = cellWidth - 2 * paddingSide - indent
		return text.height(withConstrainedWidth: textWidth, font: .lightRescounts(ofSize: 15))
	}
	
	private func setupLabel(_ label: UILabel, font: UIFont, text: String? = "", colour: UIColor, alignment: NSTextAlignment = .left, numLines: Int = 1) {
		label.backgroundColor = .clear
		label.textColor = colour
		label.font = font
		label.textAlignment = alignment
		label.text = text
		label.numberOfLines = numLines
	}
	
	// MARK: - UIView Methods
	override func layoutSubviews() {
		titleLabel.frame = CGRect(MyAccountTableViewCell.paddingSide, self.frame.height/2 - MyAccountTableViewCell.lineHeight/2, (titleLabel.text?.width(withConstrainedHeight: self.frame.height, font: .lightRescounts(ofSize: 15))) ?? 0, MyAccountTableViewCell.lineHeight)
		let textFieldWidth = self.frame.width - titleLabel.frame.maxX - 4 - MyAccountTableViewCell.paddingSide
		textField.frame = CGRect(titleLabel.frame.maxX + 4, self.frame.height/2 - MyAccountTableViewCell.lineHeight/2, textFieldWidth, MyAccountTableViewCell.lineHeight)
		// Separator
		separator.frame = CGRect(0, frame.size.height - ProfileBasicTableViewCell.separatorHeight, frame.width, ProfileBasicTableViewCell.separatorHeight)
	}

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		if data?.valueType == .phoneNumber {
			
			let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
			let components = (newString as NSString).components(separatedBy: NSCharacterSet.decimalDigits.inverted)
			
			let decimalString = components.joined(separator: "") as NSString
			let length = decimalString.length
			let hasLeadingOne = length > 0 && decimalString.character(at: 0) == (1 as unichar)
			
			if length == 0 || (length > 10 && !hasLeadingOne) || length > 11 {
				let newLength = (textField.text! as NSString).length + (string as NSString).length - range.length as Int
				return (newLength > 10) ? false : true
			}
			
			var index = 0 as Int
			let formattedString = NSMutableString()
			
			if hasLeadingOne {
				formattedString.append("1 ")
				index += 1
			}
			if (length - index) > 3 {
				let areaCode = decimalString.substring(with: NSMakeRange(index, 3))
				formattedString.appendFormat("(%@)", areaCode)
				index += 3
			}
			if length - index > 3 {
				let prefix = decimalString.substring(with: NSMakeRange(index, 3))
				formattedString.appendFormat("%@-", prefix)
				index += 3
			}
			
			let remainder = decimalString.substring(from: index)
			formattedString.append(remainder)
			textField.text = formattedString as String
			return false
			
		}
        return true
    }
	
	func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
		if let doneEditingCallback = doneEditingCallback, let text = textField.text {
			doneEditingCallback(text)
		}
		return true
	}
}
