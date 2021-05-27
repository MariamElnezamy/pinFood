//
//  BrowseListTableViewCell.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-21.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class BrowseListTableViewCell: UITableViewCell {
	let summaryView = RestaurantSummaryView()
	let separator = UIView()
	
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		commonInit()
	}
	
	private func commonInit() {
		summaryView.frame = bounds
		summaryView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		addSubview(summaryView)
		
		separator.backgroundColor = .separators
		addSubview(separator)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		separator.frame = CGRect(0, frame.height - Constants.Profile.separatorHeight, frame.width, Constants.Profile.separatorHeight)
	}

}
