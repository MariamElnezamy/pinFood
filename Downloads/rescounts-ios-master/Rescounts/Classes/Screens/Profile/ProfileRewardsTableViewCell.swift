//
//  ProfileRewardsTableViewCell.swift
//  Rescounts
//
//  Created by Kittiphong Xayasane on 2018-08-14.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class ProfileRewardsTableViewCell: UITableViewCell {
	public var item: [ProfileRewardItem]? {
		didSet { prepareForDisplay() }
	}
	
	
	private let rewardLabel  				= UILabel()
	private let firstRewardView			= ProfileRewardView()
	private let secondRewardView		= ProfileRewardView()
	private let separator					= UIView()
    
    weak public var delegate: ProfileViewControllerDelegate?
    var firstRewardViewTapRecognizer : UITapGestureRecognizer?
    var secondRewardViewTapRecognizer: UITapGestureRecognizer?
    
	static let paddingTop: CGFloat = 12
	static let paddingBottom: CGFloat = 14
	static let paddingTopRewardItem: CGFloat = 8
	static let paddingSide: CGFloat = 25
	static let lineHeight: CGFloat = 20
	static let separatorHeight: CGFloat = 2
	static let photoSize: CGFloat = 23
	static let namePaddingSide: CGFloat = 28
	
	// MARK: - Initialization
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.delegate = nil
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.delegate = nil
		commonInit()
	}
	
	private func commonInit() {
        
        firstRewardViewTapRecognizer = UITapGestureRecognizer(target: self, action:  #selector(self.firstViewTapped(tap:)))
        secondRewardViewTapRecognizer = UITapGestureRecognizer(target: self, action:  #selector(self.secondViewTapped(tap:)))
		addSubview(firstRewardView)
        if let firstTap = firstRewardViewTapRecognizer {
            firstRewardView.addGestureRecognizer(firstTap)
        }
		addSubview(secondRewardView)
        if let secondTap = secondRewardViewTapRecognizer {
            secondRewardView.addGestureRecognizer(secondTap)
        }
        
		addSubview(rewardLabel)
		addSubview(separator)
	}
    
    @objc func firstViewTapped(tap: UITapGestureRecognizer) {
        delegate?.profileRewardFirstItemTapped()
    }
    
    @objc func secondViewTapped(tap: UITapGestureRecognizer) {
        delegate?.profileRewardSecondItemTapped()
    }
	
	// MARK: - Public Methods
	
	public class func height(_ profileRewardItem: [ProfileRewardItem], width cellWidth: CGFloat) -> CGFloat {
		return paddingTop + paddingBottom + lineHeight + paddingTopRewardItem + lineHeight + lineHeight + separatorHeight
	}
	
	public func prepareForDisplay() {		
		setupLabel(rewardLabel,      font: UIFont.lightRescounts(ofSize: 15), text: l10n("allTimeWinnings").uppercased(), colour: .primary) //TODO: Remove
		firstRewardView.item = item?[0]
		secondRewardView.item = item?[1]
		separator.backgroundColor = .separators
	}
	
	// MARK: - Private Helpers
	
	private func setupLabel(_ label: UILabel, font: UIFont, text: String? = "", colour: UIColor, alignment: NSTextAlignment = .left, numLines: Int = 1) {
		label.backgroundColor = .clear
		label.textColor = colour
		label.font = font
		label.textAlignment = alignment
		label.text = text
		label.numberOfLines = numLines
	}
	
	private class func heightForText(_ text: String, width cellWidth: CGFloat, indent: CGFloat = 0) -> CGFloat{
		let textWidth = cellWidth - 2*paddingSide - indent
		return text.height(withConstrainedWidth: textWidth, font: profileFont())
	}
	
	private class func profileFont() -> UIFont {
		return UIFont.rescounts(ofSize: 15)
	}
	
	// MARK: -
	override func layoutSubviews() {
		rewardLabel.frame = CGRect(ProfileRewardsTableViewCell.paddingSide, ProfileRewardsTableViewCell.paddingTop, (rewardLabel.text?.width(withConstrainedHeight: ProfileRewardsTableViewCell.lineHeight, font: .lightRescounts(ofSize: 15))) ?? ProfileRewardsTableViewCell.lineHeight, ProfileRewardsTableViewCell.lineHeight)
		let rewardViewOriginY = rewardLabel.frame.height + ProfileRewardsTableViewCell.paddingTop + ProfileRewardsTableViewCell.paddingTopRewardItem
		firstRewardView.frame = CGRect(ProfileRewardsTableViewCell.paddingSide, rewardViewOriginY, self.frame.width/2, self.frame.height - rewardViewOriginY)
		secondRewardView.frame = CGRect(self.frame.width/2 + ProfileRewardsTableViewCell.paddingSide, rewardViewOriginY, self.frame.width/2 - ProfileRewardsTableViewCell.paddingSide, self.frame.height - rewardViewOriginY)
		separator.frame = CGRect(0, frame.size.height - ProfileRewardsTableViewCell.separatorHeight, frame.width, ProfileRewardsTableViewCell.separatorHeight)
	}

}
