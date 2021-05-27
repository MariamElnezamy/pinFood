//
//  MenuOptionsHeaderView.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-08-27.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import UIKit

class MenuOptionsHeaderView : UIView {
	typealias  k = Constants.Order
	
	private let thumbnail = RemoteImageView()
	private var hasImg : Bool = false
	private var restaurant: Restaurant!
	
	private let descrip = UILabel()
	private let nutrition = UILabel()
	private var caloriesDigit : Int = 0
	private let calories = UILabel()
	
	
	// MARK: - Initialization
	
	init(restaurant: Restaurant, descript : String, nutrition: String, calories : Int, imageURL: URL?){
		super.init(frame: .arbitrary)
		commonInit(menuDescript: descript, menuNutrition: nutrition, menuCalories:  calories, menuThumbnail: imageURL)
		self.restaurant = restaurant
	}
	
	required init? (coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit(menuDescript: String = "", menuNutrition: String = "", menuCalories: Int = 0, menuThumbnail : URL? = nil){
		caloriesDigit = menuCalories
		
		setupLabel(descrip, font: UIFont.lightRescounts(ofSize: 13), text: menuDescript, numLines: 0)
		
		let nutritionWords = NSMutableAttributedString(string: menuNutrition)
		if nutritionWords.string.count > 0 {
			nutritionWords.insert(NSAttributedString(string: "\n\(l10n("contains")): ", attributes: [.font: UIFont.semiBoldRescounts(ofSize: 13)]), at: 0)
		}
		setupLabel(nutrition, font: UIFont.lightRescounts(ofSize: 13), attrText: nutritionWords, numLines: 0 )
		
		let caloriesText = NSMutableAttributedString(string: "\(l10n("calories")): ", attributes: [.font: UIFont.semiBoldRescounts(ofSize: 13)])
		caloriesText.append(NSAttributedString(string: "\(menuCalories)"))
		setupLabel(calories, font: UIFont.lightRescounts(ofSize: 13), attrText: caloriesText, numLines: 0)
		calories.isHidden = (menuCalories == 0 ? true : false)
		caloriesDigit = menuCalories
		
		thumbnail.setImageURL(menuThumbnail)
		thumbnail.isHidden = (menuThumbnail == nil)
		hasImg = !(menuThumbnail == nil)
		addSubview(thumbnail)
		
		refresh()
	}
	
	
	// MARK: - Private funcs
	
	private func setupLabel(_ label: UILabel, font: UIFont, text: String? = nil, attrText: NSAttributedString? = nil, numLines: Int = 1, alignment: NSTextAlignment = .left) {
		label.backgroundColor = .clear
		label.textColor = .dark
		label.font = font
		label.textAlignment = alignment
		label.numberOfLines = numLines
		if let text = text {
			label.text = text
		} else if let attrText = attrText {
			label.attributedText = attrText
		}
		
		addSubview(label)
	}
	
	
	// MARK: - UIView Methods
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		//thumbnail.frame = CGRect((self.frame.width - k.thumbnailHeight )/2.0, 0 , k.thumbnailHeight, k.thumbnailHeight) //<-- very ugly layout
		thumbnail.frame = CGRect(0, 0 , self.frame.width, k.thumbnailHeight)
		let startingIndex = hasImg ? thumbnail.frame.maxY + k.cellPaddingTop : k.cellPaddingTop
		let descriptionWidth = frame.width - 2*k.leftMargin
		descrip.frame = CGRect(k.leftMargin, startingIndex, descriptionWidth, frame.height - 2*k.cellPaddingTop - k.textHeight)
		descrip.sizeToFit()
		
		let nutritionWidth = frame.width - 2*k.leftMargin
		nutrition.frame = CGRect(k.leftMargin, descrip.frame.maxY + 3, nutritionWidth, frame.height - 2*k.cellPaddingTop - k.textHeight)
		nutrition.sizeToFit()
		
		let caloriesHeight: CGFloat = (caloriesDigit == 0 ? 0.0 : k.textHeight)
		calories.frame = CGRect(k.leftMargin, nutrition.frame.maxY + 3, descriptionWidth, caloriesHeight)
	}
	
	
	// MARK: - Public funcs
	
	public func getIdealHeight(width: CGFloat) -> CGFloat{
		let descriptionHeight = descrip.sizeThatFits(CGSize(width - 2*k.leftMargin, 1000)).height
		let nutritionHeight = nutrition.sizeThatFits(CGSize(width - 2*k.leftMargin, 1000)).height
		let imageHeight = hasImg ? k.thumbnailHeight + 3.0 : 0.0
		var caloriesHeight : CGFloat = 0.0
		if caloriesDigit != 0 {
			caloriesHeight = k.textHeight
		}
		
		return k.cellPaddingTop * 2 + imageHeight + descriptionHeight + nutritionHeight + caloriesHeight + 10
	}
	
	public func refresh() {
		// Do nothing, all functionality has been moved to MenuOptionsFooterView
	}
}
