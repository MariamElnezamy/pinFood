//
//  BrowseListLoadMoreCell.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-10-14.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class BrowseListLoadMoreCell: UITableViewCell {

	let spinner = CircularLoadingSpinner()
	
	let kSpinnerSize: CGFloat = 30
	
	
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
		addSubview(spinner)
	}
	
	
	// MARK: - UIView Overrides
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		spinner.frame = CGRect(floor((frame.width  - kSpinnerSize) / 2),
							   floor((frame.height - kSpinnerSize) / 2),
							   kSpinnerSize,
							   kSpinnerSize)
	}
}
