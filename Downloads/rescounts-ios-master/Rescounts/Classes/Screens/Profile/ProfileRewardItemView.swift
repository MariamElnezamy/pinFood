//
//  ProfileAmountItem.swift
//  Rescounts
//
//  Created by Kittiphong Xayasane on 2018-08-14.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit



class ProfileRewardView: UIView {
	
	public var item: ProfileRewardItem? {
		didSet { prepareForDisplay() }
	}

	private let iconImage = UIImageView()
	private let amountLabel = UILabel()
	private let titleLabel = UILabel()
	
	static let amountLineHeight: CGFloat = 20
	static let titleLineHeight: CGFloat = 20
	static let iconPaddingRight: CGFloat = 5
	static let iconSize: CGFloat = 27
	
	
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
		addSubview(iconImage)
		addSubview(amountLabel)
		addSubview(titleLabel)
	}

	
	// MARK: - Public Methods
	public func prepareForDisplay() {
		setupLabel(amountLabel, font: UIFont.rescounts(ofSize: 15), text: "\(item?.amount ?? 0)")
		setupLabel(titleLabel, font: UIFont.lightRescounts(ofSize: 13), text: item?.title)
		setupThumbnail()
	}
	
	private func setupThumbnail() {
		if let iconName = item?.iconName {
			iconImage.image = UIImage(named: iconName)
		}
		iconImage.contentMode = .scaleAspectFit
		iconImage.layer.masksToBounds = true
	}
	
	
	// MARK: - UIView Methods
	
	override func layoutSubviews() {
		let titleLabelWidth = titleLabel.text?.width(withConstrainedHeight: self.frame.height, font: .lightRescounts(ofSize: 15.0)) ?? 0

		amountLabel.frame = CGRect(ProfileRewardView.iconSize + ProfileRewardView.iconPaddingRight, 0.0, titleLabelWidth, ProfileRewardView.amountLineHeight)
		titleLabel.frame = CGRect(ProfileRewardView.iconSize + ProfileRewardView.iconPaddingRight, ProfileRewardView.amountLineHeight, titleLabelWidth, ProfileRewardView.titleLineHeight)
		iconImage.frame = CGRect(0.0, amountLabel.frame.origin.y + (ProfileRewardView.amountLineHeight + ProfileRewardView.titleLineHeight)/2 - ProfileRewardView.iconSize/2, ProfileRewardView.iconSize, ProfileRewardView.iconSize)
	}
	
	
	// MARK: - Private Helpers
	
	private func setupLabel(_ label: UILabel, font: UIFont, text: String? = "", colour: UIColor = .dark, alignment: NSTextAlignment = .left, numLines: Int = 1) {
		label.backgroundColor = .clear
		label.textColor = colour
		label.font = font
		label.textAlignment = alignment
		label.text = text
		label.numberOfLines = numLines
	}
}
