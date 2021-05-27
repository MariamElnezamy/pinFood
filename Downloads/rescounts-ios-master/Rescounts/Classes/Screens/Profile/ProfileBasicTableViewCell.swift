//
//  ProfileBasicTableViewCell.swift
//  Rescounts
//
//  Created by Kittiphong Xayasane on 2018-08-13.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class ProfileBasicTableViewCell: UITableViewCell {
	
	public var item: ProfileItem? {
		didSet { prepareForDisplay() }
	}
	
	private let iconImage 	= UIImageView()
	private let nameLabel 	= UILabel()
	private let separator	 = UIView()
	
	static let paddingTop: CGFloat = 14
	static let paddingSide: CGFloat = 40
	static let lineHeight: CGFloat = 20
	static let separatorHeight: CGFloat = 2
	static let photoSize: CGFloat = 26
	static let namePaddingSide: CGFloat = 28
	
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
		addSubview(iconImage)
		addSubview(nameLabel)
		addSubview(separator)
	}
	
	// MARK: - Public Methods
	
	public class func height(_ profileItem: ProfileItem, width cellWidth: CGFloat) -> CGFloat {
		return 2 * paddingTop + max(heightForText(profileItem.title, width: cellWidth, indent: paddingSide + photoSize + namePaddingSide), photoSize) + separatorHeight
	}

	public func prepareForDisplay() {
		setupLabel(nameLabel, font: UIFont.rescounts(ofSize: 15), text: item?.title)
		setupThumbnail()
		separator.backgroundColor = .separators
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
	
	private func setupThumbnail() {
		if let iconName = item?.iconName {
			iconImage.image = UIImage(named: iconName)
		}
		iconImage.contentMode = .scaleAspectFit
		iconImage.layer.masksToBounds = true
	}
	
	private class func heightForText(_ text: String, width cellWidth: CGFloat, indent: CGFloat = 0) -> CGFloat{
		let textWidth = cellWidth - 2*paddingSide - indent
		return text.height(withConstrainedWidth: textWidth, font: profileFont())
	}
	
	private class func profileFont() -> UIFont {
		return UIFont.rescounts(ofSize: 15)
	}
	
	// MARK: - UIView Methods
	override func layoutSubviews() {
		
		// Thumbnail
		iconImage.frame = CGRect(ProfileBasicTableViewCell.paddingSide, ProfileBasicTableViewCell.paddingTop, ProfileBasicTableViewCell.photoSize, ProfileBasicTableViewCell.photoSize)
		
		// User labels
		let textWidth = frame.width - 2 * ProfileBasicTableViewCell.paddingSide
		let nameY     = self.frame.height/2 - ProfileBasicTableViewCell.lineHeight/2 - ProfileBasicTableViewCell.separatorHeight
		let nameWidth = textWidth - ProfileBasicTableViewCell.photoSize
		nameLabel.frame  = CGRect(iconImage.frame.maxX + ProfileBasicTableViewCell.namePaddingSide, nameY, nameWidth,  ProfileBasicTableViewCell.lineHeight)
		
		// Separator
		separator.frame = CGRect(0, frame.size.height - ProfileBasicTableViewCell.separatorHeight, frame.width, ProfileBasicTableViewCell.separatorHeight)
	}
}
