//
//  RestaurantReviewCell.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-30.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class RestaurantReviewCell: UITableViewCell {
	
	public enum ReviewType : Int {
		case mine
		case general
	}
	
	typealias k = Constants.Review
	
	public var review: RestaurantReview? {
		didSet { prepareForDisplay() }
	}
	
	public var reviewType: ReviewType = .general
	
	private let thumbnail      = RemoteImageView()
	private let nameLabel      = UILabel()
	private let dateLabel      = UILabel()
	private let countLabel     = UILabel()
	private let ratingLabel    = UILabel()
	private let serviceLabel   = UILabel()
	private let reviewLabel    = UILabel()
	private let replyNameLabel = UILabel()
	private let replyTextLabel = UILabel()
	private let replyDateLabel = UILabel()
	
	private let ratingStars    = StarGroup()
	private let serviceStars   = StarGroup()
	
	private let separator      = UIView()
	private let replyIndenter  = UIView()
	
	private let kDateWidth: CGFloat = 86
	
	
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
		
		contentView.addSubview(thumbnail)
		contentView.addSubview(nameLabel)
		contentView.addSubview(dateLabel)
		contentView.addSubview(countLabel)
		contentView.addSubview(ratingLabel)
		contentView.addSubview(serviceLabel)
		contentView.addSubview(reviewLabel)
		contentView.addSubview(replyNameLabel)
		contentView.addSubview(replyTextLabel)
		contentView.addSubview(replyDateLabel)
		
		contentView.addSubview(ratingStars)
		contentView.addSubview(serviceStars)
		
		addSubview(separator)
		contentView.addSubview(replyIndenter)
		
		self.selectionStyle = .none
	}
	
	
	// MARK: - Public Methods
	
	public class func heightForReview(_ review: RestaurantReview, width cellWidth: CGFloat, type: ReviewType = .general) -> CGFloat {
		let replyHeight = review.hasReply() ? k.spacer + k.lineHeight + heightForText(review.replyText ?? "", width: cellWidth, indent: k.paddingSide) : 0.0
		let headerHeight = (type == .general) ? k.photoSize : k.lineHeight
		
		var reviewTxtHeight = heightForText(review.reviewText, width: cellWidth) + k.spacer
		if(review.reviewText == "" && !review.hasReply()) {
			reviewTxtHeight = 0.0
		}
		return
			2 * k.paddingTop +
			1 * k.spacer +
			headerHeight +
			2 * k.lineHeight +
			reviewTxtHeight +
			replyHeight
	}
	
	public func prepareForDisplay() {
		setupLabel(nameLabel,      font: UIFont.rescounts(ofSize: 15), text: (reviewType == .general) ? review?.userDisplayName : review?.replyName)
		setupLabel(dateLabel,      font: type(of: self).reviewFont(),  text: review?.timestampAsString(), colour: .lightGrayText, alignment: .right)
		setupLabel(countLabel,     font: type(of: self).reviewFont(),  text: review?.reviewCountAsString())
		setupLabel(ratingLabel,    font: UIFont.rescounts(ofSize: 13), text: l10n("overall"), colour: .lightGrayText)
		setupLabel(serviceLabel,   font: UIFont.rescounts(ofSize: 13), text: l10n("service"), colour: .lightGrayText)
		setupLabel(reviewLabel,    font: type(of: self).reviewFont(),  text: review?.reviewText, numLines: 0)
		setupLabel(replyNameLabel, font: UIFont.rescounts(ofSize: 15), text: review?.replyName)
		setupLabel(replyTextLabel, font: type(of: self).reviewFont(),  text: review?.replyText, numLines: 0)
		setupLabel(replyDateLabel, font: type(of: self).reviewFont(),  text: review?.lastEditedAsString(), colour: .lightGrayText, alignment: .right)
		
		countLabel.isHidden = (reviewType == .mine)
		
		setupStars(ratingStars,  rating: review?.rating)
		setupStars(serviceStars, rating: review?.serverRating)
		
		setupThumbnail()
		
		separator.backgroundColor = .separators
		replyIndenter.backgroundColor = .separators
		
		let replyAvailable = (review?.hasReply() ?? false)
		replyNameLabel.isHidden = !replyAvailable
		replyTextLabel.isHidden = !replyAvailable
		replyDateLabel.isHidden = !replyAvailable
		replyIndenter.isHidden  = !replyAvailable
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
		if (reviewType == .general) {
			thumbnail.backupImageName = "ProfileDefault"
			thumbnail.setImageURL(review?.userPhotoURL, usePlaceholderIfNil: true)
			thumbnail.layer.cornerRadius = ceil(k.photoSize * 0.34)
			thumbnail.layer.masksToBounds = true
			thumbnail.isHidden = false
		} else {
			thumbnail.setImageURL(nil)
			thumbnail.isHidden = true
		}
		
		thumbnail.layer.cornerRadius = floor(k.photoSize / 4)
		thumbnail.layer.masksToBounds = true
	}
	
	private func setupStars(_ stars: StarGroup, rating: Float?) {
		stars.setValue(rating ?? 0, maxValue: Constants.Restaurant.maxRating)
		stars.setColours(on: .gold)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		// Thumbnail
		var nameX = k.paddingSide
		var ratingY = k.paddingTop + k.lineHeight + k.spacer
		if (reviewType == .general) {
			thumbnail.frame = CGRect(k.paddingSide, k.paddingTop, k.photoSize, k.photoSize)
			nameX = thumbnail.frame.maxX + k.spacer
			ratingY = thumbnail.frame.maxY + k.spacer
		}
		
		// User labels
		let textWidth = frame.width - 2 * k.paddingSide
		let nameY     = k.paddingTop + floor(0.5 * (k.photoSize - 2*k.lineHeight))
		let dateX     = frame.width - k.paddingSide - kDateWidth
		let nameWidth = frame.width - nameX - kDateWidth - k.paddingSide
		nameLabel.frame  = CGRect(nameX, nameY, nameWidth,  k.lineHeight)
		countLabel.frame = CGRect(nameX, nameLabel.frame.maxY, nameWidth, k.lineHeight)
		dateLabel.frame  = CGRect(dateX, nameY, kDateWidth, k.lineHeight)
		
		// Ratings
		let starWidth = ratingStars.idealWidthForHeight(k.lineHeight)
		ratingLabel.frame  = CGRect(k.paddingSide, ratingY, starWidth, k.lineHeight)
		ratingStars.frame  = CGRect(k.paddingSide, ratingLabel.frame.maxY, starWidth, k.lineHeight)
		serviceLabel.frame = CGRect(ratingLabel.frame.maxX + 2*k.spacer, ratingY, starWidth, k.lineHeight)
		serviceStars.frame = CGRect(ratingLabel.frame.maxX + 2*k.spacer, serviceLabel.frame.maxY, starWidth, k.lineHeight)
		
		// Review
		let reviewTextHeight = type(of: self).heightForText(review?.reviewText ?? "", width: frame.width)
		reviewLabel.frame = CGRect(k.paddingSide, ratingStars.frame.maxY + k.spacer, textWidth, reviewTextHeight)
		
		// Reply
		if let replyText = review?.replyText {
			let replyTextHeight = type(of: self).heightForText(replyText, width: frame.width, indent: k.paddingSide)
			let replyDateX = frame.width - kDateWidth - k.paddingSide
			replyNameLabel.frame = CGRect(2 * k.paddingSide, reviewLabel.frame.maxY + k.spacer, textWidth - k.paddingSide - kDateWidth, k.lineHeight)
			replyDateLabel.frame = CGRect(replyDateX, replyNameLabel.frame.minY, kDateWidth, k.lineHeight)
			replyTextLabel.frame = CGRect(2 * k.paddingSide, replyNameLabel.frame.maxY, textWidth - k.paddingSide, replyTextHeight)
			replyIndenter.frame  = CGRect(k.paddingSide, replyNameLabel.frame.minY, k.separatorHeight, k.lineHeight + replyTextHeight)
		}
		
		// Separator
		separator.frame = CGRect(0, frame.size.height - k.separatorHeight, frame.width, k.separatorHeight)
	}
	
	private class func heightForText(_ text: String, width cellWidth: CGFloat, indent: CGFloat = 0) -> CGFloat{
		if text.count == 0 {
			return 0
		} else {
			let textWidth = cellWidth - 2*k.paddingSide - indent
			return text.height(withConstrainedWidth: textWidth, font: reviewFont())
		}
	}
	
	private class func reviewFont() -> UIFont {
		return UIFont.lightRescounts(ofSize: 13)
	}
}
