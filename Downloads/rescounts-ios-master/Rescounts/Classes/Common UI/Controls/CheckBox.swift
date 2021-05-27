//
//  CheckBox.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-30.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class CheckBox: UIControl {
	
	private let border = UIView()
	private let dot = UIView()
	private let label = UILabel()
	private let label2 = UILabel()
	private var iconDisabledImage = UIImageView()
	private var isRadio: Bool = false
	
	
	internal var groupIndex: Int = 0 // Used by RadioButtonGroup
	
	public var lineHeight: CGFloat = 20
	
	public var on: Bool = false {
		didSet {
			if (oldValue != on) {
				update()
				self.sendActions(for: .valueChanged)
			}
		}
	}
	
	private static let kSpacer: CGFloat = 10
	
	
	// MARK: - Initialization
	
	convenience init(text: String, text2: String = "" ,isRadio: Bool = false) {
		self.init(frame: .arbitrary, text: text, text2: text2, isRadio: isRadio)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	init(frame: CGRect, text: String, text2: String = "", isRadio: Bool = false) {
		super.init(frame: frame)
		commonInit(text: text, text2: text2, isRadio: isRadio)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit(text: String = "", text2 : String = "", isRadio: Bool = false) {
		self.isRadio = isRadio
		
		self.border.layer.masksToBounds = true
		self.border.layer.borderWidth = 2
		self.border.layer.borderColor = UIColor.lightGrayText.cgColor
		self.border.isUserInteractionEnabled = false
		self.addSubview(self.border)
		
		self.dot.backgroundColor = .gold
		self.dot.layer.masksToBounds = true
		self.dot.isUserInteractionEnabled = false
		self.border.addSubview(self.dot)
		
		self.label.text = text
		self.label.font = CheckBox.labelFont()
		self.label.textColor = .dark
		self.addSubview(self.label)
		
		self.label2.text = text2
		self.label2.font = CheckBox.labelFont()
		self.label2.textColor = .dark
		self.label2.textAlignment = .right
		self.addSubview(self.label2)
		
		let image = UIImage(named: "iconOptionDisabled")
		self.iconDisabledImage = UIImageView(image: image)
		self.iconDisabledImage.isHidden = true
		self.border.addSubview(self.iconDisabledImage)
		
		self.addAction(for: .touchUpInside) { [weak self] in
			self?.toggle()
		}
		
		update()
	}
	
	
	// MARK: - UIView Methods
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.border.layer.borderWidth = round(lineHeight / 15)
		self.border.frame = CGRect(0, 0, lineHeight, lineHeight)
		self.dot.frame = self.border.bounds.insetBy(lineHeight / 4)
		
		if (isRadio) {
			self.border.layer.cornerRadius = floor(lineHeight / 2)
			self.dot.layer.cornerRadius = floor(self.dot.frame.height / 2)
		}
		
		let labelX = self.border.frame.maxX + CheckBox.kSpacer
		let label2Width = (label2.text?.count ?? 0) > 0 ? ceil(min(frame.width/2, label2.text?.width(withConstrainedHeight: lineHeight, font: label2.font) ?? 0)) : 0
		self.label.frame = CGRect(labelX, 0, frame.width - labelX - label2Width, frame.height)
		self.label2.frame = CGRect(frame.width - label2Width, label.frame.minY, label2Width, lineHeight)
		
		self.iconDisabledImage.frame = CGRect(0,0,border.frame.width, border.frame.height)
		
	}
	
	
	// MARK: - Public Methods
	
	public func idealHeight(width: CGFloat) -> CGFloat{
		return CheckBox.heightFor(text1: label.text ?? "", text2: label2.text ?? "", width: width, lineHeight: lineHeight)
	}
	
	public static func heightFor(text1: String, text2: String, width: CGFloat, lineHeight: CGFloat) -> CGFloat {
		let font = labelFont()
		let labelX = lineHeight + kSpacer
		let label2Width = (text2.count > 0) ? ceil(min(width/2, text2.width(withConstrainedHeight: lineHeight, font: font))) : 0
		let label1Width = width - labelX - label2Width
		
		return text1.height(withConstrainedWidth: label1Width, font: font)
	}
	
	public func allowMultiline(_ allow: Bool) {
		label.numberOfLines = allow ? 0 : 1
	}
	
	public func wakeUp(){ //The user has selected this rest, uncover the dot for menu options selections
		self.isUserInteractionEnabled = true
		self.iconDisabledImage.isHidden = true
	}
	public func goSleep(){
		self.isUserInteractionEnabled = false
		self.iconDisabledImage.isHidden = false
	}
	public func setTextColor(color: UIColor) {
		self.label.textColor = color
		self.label2.textColor = color
	}
	
	
	// MARK: - Private Helpers
	
	private func toggle() {
		self.on = !self.on
	}
	
	private func update() {
		self.dot.isHidden = !self.on
	}
	
	private static func labelFont() -> UIFont {
		return UIFont.rescounts(ofSize: 15)
	}
}
