//
//  RemoteImageCollectionCell.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-25.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class RemoteImageCollectionCell: UICollectionViewCell {

	public let imageView = RemoteImageView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		imageView.frame = self.contentView.bounds
		imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.contentView.addSubview(imageView)
	}
}
