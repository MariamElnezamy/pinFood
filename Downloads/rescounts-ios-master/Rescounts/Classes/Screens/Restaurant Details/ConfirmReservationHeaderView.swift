//
//  ConfirmReservationHeaderView.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-08-22.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import UIKit


class ConfirmReservationHeaderView : UIView {
	private var headerTitle = UILabel()
	private var headerPeople = UILabel()
	private var headerTime = UILabel()
	private var separator = UILabel()
	private let kMargin : CGFloat = 10
	
	// MARK : Initialization
	
	init(frame: CGRect, restaurant : Restaurant , numPeople : Int = 0, desiredTime : Date = Date() ){
		super.init(frame: frame)
		commonInit(restaurant : restaurant, numPeople : numPeople, desiredTime: desiredTime)
		
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	

	private func commonInit(restaurant : Restaurant, numPeople : Int = 0, desiredTime : Date){
		headerTitle.text = restaurant.name
		headerTitle.font = UIFont.rescounts(ofSize: 14)
		
//		headerPeople.text = "\(numPeople) People"
//		headerPeople.font = UIFont.lightRescounts(ofSize: 13)
//
//		headerTime.text = HoursManager.userFriendlyDate(desiredTime)
//		headerTime.font = UIFont.lightRescounts(ofSize: 13)
//		headerTime.textAlignment = .right
		
		
		separator.backgroundColor = UIColor.separators
		
		addSubview(headerTitle)
//		addSubview(headerPeople)
//		addSubview(headerTime)
		addSubview(separator)
	}
	
	// MARK: private funcs
	private func setupFrames (){
		headerTitle.frame = CGRect(Constants.Order.leftMargin , kMargin, self.frame.width, Constants.Order.textHeight)
//		headerPeople.frame = CGRect(Constants.Order.leftMargin , headerTitle.frame.maxY + Constants.Order.spacer * 2, self.frame.width, Constants.Order.textHeight)
//		headerTime.frame = CGRect(0, headerPeople.frame.minY,self.frame.width - Constants.Order.leftMargin, Constants.Order.textHeight)
		separator.frame = CGRect(0, self.frame.height - Constants.Menu.separatorHeight, self.frame.width, Constants.Menu.separatorHeight )
	}
	
	// MARK: public funcs
	public func getIdealHeight() -> CGFloat{
		return 2*kMargin + Constants.Order.textHeight
	}
	
	override func layoutSubviews(){
		super.layoutSubviews()
		setupFrames()
	}
	
}
