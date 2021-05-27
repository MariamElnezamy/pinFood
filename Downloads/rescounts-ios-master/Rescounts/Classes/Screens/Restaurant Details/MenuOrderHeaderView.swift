//
//  MenuOrderHeaderView.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-08-21.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import UIKit

//This is the MenuOrderTableViewCell header talking about the restaurant info
class MenuOrderHeaderView : UIView {
	typealias k = Constants.Order
	
	private var restaurantName = String()
	private var restaurantAddress = String()
	private let nameLabel = UILabel()
	private let addressLabel = UILabel()
	private let reservationLabel = UILabel()
	private let tableCodeLabel = UILabel()
	private var table: RestaurantTable?
	
	private let titleFont : CGFloat = 15
	private let infoWidth : CGFloat = 150
	private let kMarginBottom: CGFloat = 20
	private let kReservationHeight: CGFloat = 20
	
	
	// MARK: - Initialization
	
	init(name : String, address : String, table: RestaurantTable? = nil) {
		super.init(frame: .arbitrary)
		commonInit(restaurantName : name, restaurantAddress : address, table: table)
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	private func commonInit(restaurantName : String = "", restaurantAddress : String = "", table: RestaurantTable? = nil) {
		self.restaurantName = restaurantName
		self.restaurantAddress = restaurantAddress
		self.table = table
		setupUI()
	}
	
	
	// MARK: - UIView Methods
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let nameWidth = self.frame.width - 2*k.leftMargin
		nameLabel.frame = CGRect(k.leftMargin, k.cellPaddingTop, nameWidth, k.textHeight)
		
		let reservationWidth = ceil(reservationLabel.sizeThatFits(CGSize(infoWidth, kReservationHeight)).width)
		reservationLabel.frame = CGRect(frame.width - k.leftMargin - reservationWidth, nameLabel.frame.maxY + k.spacer, reservationWidth, kReservationHeight)
		
		let codeWidth = ceil(tableCodeLabel.sizeThatFits(CGSize(infoWidth, kReservationHeight)).width)
		tableCodeLabel.frame = CGRect(frame.width - k.leftMargin - codeWidth, reservationLabel.frame.maxY, codeWidth, kReservationHeight)
		
		let addressSize = addressLabel.sizeThatFits(CGSize(nameWidth - max(reservationWidth, codeWidth) - k.spacer, 1000))
		addressLabel.frame = CGRect( k.leftMargin, nameLabel.frame.maxY + k.spacer, ceil(addressSize.width), ceil(addressSize.height) )
	}
	
	
	// MARK: - Public Funcs
	
	public func idealHeight(forWidth viewWidth: CGFloat) -> CGFloat {
		let reservationWidth = ceil(reservationLabel.sizeThatFits(CGSize(infoWidth, kReservationHeight)).width)
		let codeWidth = ceil(tableCodeLabel.sizeThatFits(CGSize(infoWidth, kReservationHeight)).width)
		let addressSize = addressLabel.sizeThatFits(CGSize(viewWidth - 2*k.leftMargin - max(reservationWidth, codeWidth) - k.spacer, 1000))
		
		return 2*k.cellPaddingTop + k.textHeight + k.spacer + max( ceil(addressSize.height), 2*kReservationHeight )
	}
	
	
	// MARK: - Private Funcs
	
	private func setupUI() {
		let tableCode = NSMutableAttributedString(string:"Table Code: ")
		tableCode.append(NSAttributedString(string: "\(table?.joinCode ?? "")", attributes: [.foregroundColor: UIColor.primary]))
		
		setupLabel(nameLabel, font: UIFont.rescounts(ofSize: titleFont), text: self.restaurantName, numLines: 0)
		setupLabel(addressLabel, font: UIFont.lightRescounts(ofSize: k.detailFontSize), text: self.restaurantAddress, numLines: 0)
		setupLabel(reservationLabel, font: UIFont.lightRescounts(ofSize: k.detailFontSize), text: table?.reservationDetails, numLines: 1, alignment: .right)
		setupLabel(tableCodeLabel, font: UIFont.lightRescounts(ofSize: k.detailFontSize), attrText: tableCode, numLines: 1, alignment: .right, hidden: table?.pickup ?? false)
		//setupPhoto()
	}
	
	private func setupLabel(_ label: UILabel, font: UIFont, text: String? = nil, attrText: NSAttributedString? = nil, numLines: Int = 1, alignment: NSTextAlignment = .left, hidden: Bool = false) {
		label.backgroundColor = .clear
		label.textColor = .dark
		label.font = font
		label.textAlignment = alignment
		label.numberOfLines = numLines
		label.isHidden = hidden
		if let text = text {
			label.text = text
		} else {
			label.attributedText = attrText
		}
		addSubview(label)
	}
}
