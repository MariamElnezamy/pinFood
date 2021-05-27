//
//  PhotoButton.swift
//  Rescounts
//
//  Created by Kittiphong Xayasane on 2018-08-20.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class PhotoButton: UIButton {
	private let addPhotoImage = UIImageView(image: UIImage(named: "iconAddphoto"))
	
	private var photoImageView = UIImageView()
	private let kAddPhotoImageSize: CGFloat = 33
	// MARK: - Initialization
	
	public var photoImage: UIImage? {
		didSet { update() }
	}

	convenience init() {
		self.init(frame: .arbitrary)
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
		backgroundColor = UIColor.lighterGray
		addPhotoImage.contentMode = .scaleAspectFit
		addSubview(addPhotoImage)
		photoImageView.isHidden = true
		photoImageView.contentMode = .scaleAspectFill
		photoImageView.clipsToBounds = true
		addSubview(photoImageView)
	}

	override func layoutSubviews() {
		addPhotoImage.frame = CGRect(frame.width/2 - kAddPhotoImageSize/2, frame.height/2 - kAddPhotoImageSize/2, kAddPhotoImageSize, kAddPhotoImageSize)
		photoImageView.frame = bounds
	}

	// MARK: - Private Helper
	private func update() {
		photoImageView.image = photoImage
		photoImageView.isHidden = photoImage == nil
	}

}
