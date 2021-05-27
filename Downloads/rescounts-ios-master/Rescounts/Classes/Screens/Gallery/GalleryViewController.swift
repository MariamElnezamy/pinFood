//
//  GalleryViewController.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-13.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController {

	private var carousel = ImageCarouselView()
	
	// MARK: - Initialization
	
	init(imageURLs: [URL], startingIndex: Int = 0) {
		super.init(nibName: nil, bundle: nil)
		commonInit()
		
		carousel.setImageURLs(imageURLs, contentMode: .scaleAspectFit, startingIndex: startingIndex)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
	}
	
	
	// MARK: - UIViewController Methods
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = .black
		self.automaticallyAdjustsScrollViewInsets = false
		self.carousel.setZoomingEnabled(true)

		view.addSubview(carousel)
    }
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		
		carousel.frame = view.bounds
	}
	
	// MARK: - Private Helpers
	
}
