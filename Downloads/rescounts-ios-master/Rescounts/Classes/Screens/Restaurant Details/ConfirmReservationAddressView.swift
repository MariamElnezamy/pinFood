//
//  ConfirmReservationAddressView.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-08-22.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import UIKit

class ConfirmReservationAddressView : UIView {
	
	private var addressLabel = UILabel()
	private var directionLabel = UILabel()
	private var directionDigitLabel = UILabel()
	private var separator = UIView()

	private var descriptionWidth : CGFloat = 170
	private let spacer : CGFloat = 7
	
	// MARK: Initialization
	init(frame: CGRect, restaurant : Restaurant){
		super.init(frame: frame)
		commonInit(restaurant : restaurant)
		
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	private func commonInit( restaurant : Restaurant){
		addressLabel.text = restaurant.address
		addressLabel.font = UIFont.lightRescounts(ofSize: 15)
		addressLabel.textColor = .dark
		addressLabel.numberOfLines = 0
		
		directionLabel.text = "Directions"
		directionLabel.font = UIFont.rescounts(ofSize: 15)
		directionLabel.textColor = .gold
		directionLabel.textAlignment = .right
		
		directionDigitLabel.text = "\(LocationManager.displayDistanceToLocation(restaurant.location))"
		directionDigitLabel.font = UIFont.lightRescounts(ofSize: 15)
		directionDigitLabel.textColor = .gray
		directionDigitLabel.textAlignment = .right
		
		separator.backgroundColor = UIColor.separators
		
		addSubview(addressLabel)
		addSubview(directionLabel)
		addSubview(directionDigitLabel)
		addSubview(separator)
	}
	
	// MARK: private layout
	
	private func setupFrames() {
		let descriptionHeight = addressLabel.sizeThatFits(CGSize(descriptionWidth, 1000)).height
		addressLabel.frame = CGRect(Constants.Order.leftMargin, Constants.Order.cellPaddingTop - spacer,  descriptionWidth, descriptionHeight)
		directionLabel.frame = CGRect(0, Constants.Order.cellPaddingTop - spacer, self.frame.width - Constants.Order.leftMargin, Constants.Order.textHeight)
		directionDigitLabel.frame = CGRect(0, directionLabel.frame.maxY , self.frame.width - Constants.Order.leftMargin, Constants.Order.textHeight)
		separator.frame = CGRect(0, self.frame.height - Constants.Menu.separatorHeight, self.frame.width, Constants.Menu.separatorHeight )
	}
	
	override func layoutSubviews(){
		super.layoutSubviews()
		setupFrames()
	}
	
	// MARK: public funcs
	public func getIdealHeight() -> CGFloat{
		let descriptionHeight = addressLabel.sizeThatFits(CGSize(descriptionWidth, 1000)).height
		if descriptionHeight >= 35.0 {
			return Constants.Order.cellPaddingTop * 2 - spacer * 2 + descriptionHeight
		} else {
			return Constants.Order.cellPaddingTop * 2 - spacer * 2 + 35
		}
		
	}
}
