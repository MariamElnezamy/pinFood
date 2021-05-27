//
//  RestaurantSummaryView.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-19.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class RestaurantSummaryView: UIView {

	public private(set) var restaurant: Restaurant?
	
	let imageView      = RemoteImageView()
	let starView       = StarGroup()
	let nameLabel      = UILabel()
	let cuisineLabel   = UILabel()
	let costLabel      = UILabel()
	let distanceLabel  = UILabel()
	let rDealsLabel    = UILabel()
	
	let kTextMargin: CGFloat = 10.0
	let kTitleFontSize: CGFloat = 15.0
	let kDetailFontSize: CGFloat = 13.0
	let kTitleHeight: CGFloat = 26.0
	let kDetailHeight: CGFloat = 18.0
	let kStarHeight: CGFloat = 18.0
	
	
	// MARK: - Initialization
	convenience init() {
		self.init(frame: CGRect(0.0, 0.0, 200.0, 100.0)) // Arbitrary size for autoresizing
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
		self.backgroundColor = .white
		
//		imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth, .flexibleRightMargin]
		imageView.backupImageName = "RestaurantPlaceholder"
		imageView.contentMode = .scaleAspectFit
		imageView.setImageURL(nil)
		addSubview(imageView)
		
		nameLabel.font = UIFont.rescounts(ofSize: kTitleFontSize)
		addSubview(nameLabel)
		
		starView.setColours(on: .gold)
		starView.isUserInteractionEnabled = false
		addSubview(starView)
		
		cuisineLabel.font = UIFont.lightRescounts(ofSize: kDetailFontSize)
		addSubview(cuisineLabel)
		
		costLabel.font = UIFont.lightRescounts(ofSize: kDetailFontSize)
		costLabel.textAlignment = .right
		addSubview(costLabel)
		
		distanceLabel.font = UIFont.lightRescounts(ofSize: kDetailFontSize)
		distanceLabel.textAlignment = .right
		distanceLabel.textColor = .lightGrayText
		addSubview(distanceLabel)
		
		rDealsLabel.font = UIFont.rescounts(ofSize: kDetailFontSize)
		rDealsLabel.textColor = .primary
		addSubview(rDealsLabel)
	}
	
	
	// MARK: - UIView Methods
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		imageView.frame = CGRect(0.0, 0.0, frame.height, frame.height)
		
		let hasDeal = restaurant?.rDealsInfo != nil
		var textX = imageView.frame.maxX + kTextMargin
		let rightTextWidth  = floor(frame.width * 0.2)
		let leftTextWidth   = frame.size.width - textX - rightTextWidth - kTextMargin
		let fullTextWidth   = frame.size.width - textX - kTextMargin
		let contentHeight   = kTitleHeight + 2*kDetailHeight + (hasDeal ? kDetailHeight : 0)
		let contentY        = floor((frame.height - contentHeight) / 2)
		
		nameLabel.frame     = CGRect(textX, contentY, fullTextWidth, kTitleHeight)
		starView.frame      = CGRect(textX, nameLabel.frame.maxY, leftTextWidth , kStarHeight)
		cuisineLabel.frame  = CGRect(textX, nameLabel.frame.maxY + kDetailHeight, leftTextWidth, kDetailHeight)
		rDealsLabel.frame   = CGRect(textX, cuisineLabel.frame.maxY, fullTextWidth, hasDeal ? kDetailHeight : 0)
		
		textX = frame.width - rightTextWidth - kTextMargin
		costLabel.frame     = CGRect(textX, nameLabel.frame.maxY, rightTextWidth, kDetailHeight)
		distanceLabel.frame = CGRect(textX, costLabel.frame.maxY, rightTextWidth, kDetailHeight)
	}
	
	
	// MARK: - Public Methods
	
	public func setRestaurant(_ restaurant: Restaurant?, rDealsMode: Bool = false) {
		self.restaurant = restaurant
		
		imageView.setImageURL(restaurant?.thumbnailURL, usePlaceholderIfNil: true)
		nameLabel.text = restaurant?.name
		cuisineLabel.text = restaurant?.cuisineTypesAsString()
		costLabel.text = restaurant?.averagePriceAsString(short: true)
		starView.setValue((restaurant?.numRatings ?? 0) > 0 ? (restaurant?.rating ?? 0) : 5, maxValue: Constants.Restaurant.maxRating, numReviews: restaurant?.numRatings)
		
		if let r = restaurant {
			distanceLabel.text = LocationManager.displayDistanceToLocation(r.location)
		} else {
			distanceLabel.text = nil
		}
		
		if let deal = restaurant?.rDealsInfo, deal.numItems > 0 {
			let dealText = rDealsMode ?
				"Save in \(deal.numItems) Menu Items - \(deal.displayAmount) OFF" :
				"Save on \(deal.numItems) items"
				
			rDealsLabel.attributedText = RDeals.replaceTitleIn(dealText, .rDealsDarkR, size: 20, titleAttrs: [.foregroundColor: UIColor.dark], otherAttrs: [.foregroundColor: UIColor.primary])
		} else {
			rDealsLabel.attributedText = nil
		}
		setNeedsLayout()
	}
	
	
	// MARK: - Private Helpers
	
}
