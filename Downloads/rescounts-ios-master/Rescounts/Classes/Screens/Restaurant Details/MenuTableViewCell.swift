//
//  MenuTableViewCell.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-09.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
	typealias k = Constants.Menu
	
	public var item: MenuItem?
	
	private let sectionBG    = UIView()
	private let sectionLabel = UILabel()
	private let titleLabel   = UILabel()
	private let descrLabel   = UILabel()
	private let priceLabel   = StyledLabel()
	private let rDealsLabel  = UILabel()
	private let thumbnail    = RemoteImageView()
	private let separator    = UIView()
	
	private let kThumbnailSpacer: CGFloat = 5
	private var isRDeals: Bool = false
	
	
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
		selectionStyle = .none
		
		sectionBG.backgroundColor = .gold
		sectionBG.addSubview(sectionLabel)
		
		addSubview(sectionBG)
		addSubview(titleLabel)
		addSubview(descrLabel)
		addSubview(priceLabel)
		addSubview(rDealsLabel)
		addSubview(thumbnail)
		addSubview(separator)
	}
	
	
	// MARK: - UITableViewCell Overrides
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)
		
		self.backgroundColor = highlighted ? UIColor(white: 0.85, alpha: 1) : .white
	}
	
	
	// MARK: - Public Methods
	
	public class func heightForItem(_ item: MenuItem, width cellWidth: CGFloat, isRDeals: Bool) -> CGFloat {
		var bodyHeight = heightForBody(item.details, item.hasThumbnail, width: cellWidth)
		if (bodyHeight > 0.1) { bodyHeight += k.spacer }
		
		
		// If priceWidth or dealWidth changes, also update layoutSubviews
		let priceWidth = min(k.priceWidth, item.displayPrice.width(withConstrainedHeight: k.priceHeight, font: detailFont()))
		let dealWidth = (isRDeals && item.hasDeal) ? min(k.priceWidth, item.rDealsDisplayPrice.width(withConstrainedHeight: k.priceHeight, font: detailFont())) + 5 : 0
		let maxTitleWidth = cellWidth - 2*k.padding - priceWidth - dealWidth - k.priceSpacer
		
		return
			heightForTitle(item.title, width: maxTitleWidth) +
			2 * k.paddingTop +
			bodyHeight +
			(item.isFirstInSection ? k.sectionHeaderHeight : 0)
	}
	
	public func prepareForDisplay(isRDeals: Bool) {
		self.isRDeals = isRDeals
		
		setupLabel(sectionLabel, font: UIFont.lightRescounts(ofSize: 17), text: item?.sectionName.uppercased(), numLines: 1)
		setupLabel(titleLabel,   font: type(of: self).titleFont(), text: item?.title, numLines: 0)
		setupLabel(descrLabel,   font: type(of: self).descriptionFont(), text: item?.details, numLines: 4)
		setupLabel(priceLabel,   font: type(of: self).detailFont(), text: item?.displayPrice, alignment: .right)
		setupLabel(rDealsLabel,  font: type(of: self).detailFont(), text: isRDeals ? item?.rDealsDisplayPrice : nil, color: .primary, alignment: .right)
		
		applyRDealsStyling()
		
		thumbnail.setImageURL(item?.thumbnail)
		thumbnail.isHidden = (item?.thumbnail == nil)
		
		sectionBG.isHidden = !(item?.isFirstInSection ?? true)
		
		separator.backgroundColor = .separators
	}
	
	
	// MARK: - Private Helpers
	
	private func setupLabel(_ label: UILabel, font: UIFont, text: String? = "", numLines: Int = 1, color: UIColor = .dark, alignment: NSTextAlignment = .left) {
		label.backgroundColor = .clear
		label.textColor = color
		label.font = font
		label.textAlignment = alignment
		label.text = text
		label.numberOfLines = numLines
	}
	
	private func applyRDealsStyling() {
		let hasDeal = (isRDeals && item?.hasDeal == true)
		priceLabel.textColor = hasDeal ? .lightGrayText : .dark
		priceLabel.applyStrikeThrough(hasDeal)
		priceLabel.isHidden = (hasDeal && item?.price == 0)
	}
	
	override func layoutSubviews() {
		// If priceWidth or dealWidth changes, also update heightForItem()
		let dealWidth = (isRDeals && item?.hasDeal == true) ? min(k.priceWidth, ceil(item?.rDealsDisplayPrice.width(withConstrainedHeight: k.priceHeight, font: type(of: self).detailFont()) ?? 0)) + 5 : 0
		let priceWidth = min(k.priceWidth, ceil(item?.displayPrice.width(withConstrainedHeight: k.priceHeight, font: type(of: self).detailFont()) ?? 0))
		let titleWidth = frame.width - 2*k.padding - priceWidth - dealWidth - k.priceSpacer
		let titleY = k.paddingTop + ((item?.isFirstInSection ?? false) ? k.sectionHeaderHeight : 0)
		let titleHeight = type(of: self).heightForTitle(titleLabel.text ?? "", width: titleWidth)
		let descriptionHeight = type(of: self).heightForBody(descrLabel.text ?? "", item?.hasThumbnail ?? false, width: frame.width)
		let thumbnailSize = frame.height - titleY - titleHeight - k.padding
		let thumbnailAdjustment = (item?.thumbnail != nil) ? thumbnailSize + k.padding : 0
		let detailTextX = k.padding + thumbnailAdjustment
		let detailTextWidth = frame.width - detailTextX - k.padding
		
		sectionBG.frame = CGRect(0, 0, frame.width, k.sectionHeaderHeight)
		sectionLabel.frame = CGRect(k.padding, 0, frame.width - 2*k.padding, k.sectionHeaderHeight)
		
		titleLabel.frame = CGRect(k.padding, titleY, titleWidth, titleHeight)
		descrLabel.frame = CGRect(detailTextX, titleLabel.frame.maxY + k.spacer, detailTextWidth, descriptionHeight)
		
		
		rDealsLabel.frame = CGRect(frame.width - dealWidth - k.padding, titleY, dealWidth, k.priceHeight)
		priceLabel.frame = CGRect(rDealsLabel.frame.minX - priceWidth, titleY, priceWidth, k.priceHeight)
		
		thumbnail.frame = CGRect(k.padding, titleLabel.frame.maxY + kThumbnailSpacer, thumbnailSize, thumbnailSize)
		
		separator.frame = CGRect(0, frame.size.height - k.separatorHeight, frame.width, k.separatorHeight)
	}
	
	private class func heightForTitle(_ title: String, width maxWidth: CGFloat) -> CGFloat{
		return title.height(withConstrainedWidth: maxWidth, font: titleFont())
	}
	
	private class func heightForDescription(_ text: String, width cellWidth: CGFloat) -> CGFloat{
		let textWidth = cellWidth - 2*k.padding
		return text.height(withConstrainedWidth: textWidth, font: descriptionFont())
	}
	
	private class func titleFont() -> UIFont {
		return UIFont.rescounts(ofSize: 15)
	}
	
	private class func descriptionFont() -> UIFont {
		return UIFont.lightRescounts(ofSize: 13)
	}
	
	private class func detailFont() -> UIFont {
		return UIFont.rescounts(ofSize: 13)
	}
	
	private class func heightForBody(_ descrip: String, _ hasImg : Bool,  width cellWidth: CGFloat ) -> CGFloat{
		var contentHeight : CGFloat = 0.0
		if hasImg {
			contentHeight = k.thumbnailHeight
		} else if descrip.count > 0 {
			contentHeight = min(k.thumbnailHeight, heightForDescription(descrip, width: cellWidth)) // Cap it at thumbnail height
		}
		return contentHeight
	}
	
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
	
}
