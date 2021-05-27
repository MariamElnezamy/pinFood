//
//  ImageCarouselView.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-27.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class ImageCarouselView: CarouselView {

	private let pageIndicator = UILabel()
	private let kPageIndicatorSize = CGSize(width: 70.0, height: 30.0)
	
	public var backupImageName: String?
	
	//MARK: - Initialization
	
	convenience init() {
		self.init(frame: CGRect(0.0, 0.0, 200.0, 100.0)) // Arbitrary frame for auto-resizing
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
	}

	
	//MARK: - Public Methods
	
	public func setImageURLs(_ urls: [URL], contentMode imageContentMode: UIViewContentMode = .scaleAspectFill, startingIndex: Int = 0) {
		var newPages: [UIView] = []
		
		for url in urls {
			let v = imageViewInContainer(url: url, imageContentMode: imageContentMode)
			newPages.append(v)
		}
		if (urls.count == 0) {
			let v = imageViewInContainer(url: nil, imageContentMode: imageContentMode)
			newPages.append(v)
		}
		
		self.usingPlaceholder = (urls.count == 0)
		self.pages = newPages
		if (startingIndex > 0) {
			currentIndex = startingIndex
		}
		
		
		fetchImageForIndex(startingIndex)
	}
	
	public func setZoomingEnabled(_ enabled: Bool) {
		for view in self.pages {
			if let view = view as? UIScrollView {
				view.maximumZoomScale = enabled ? 3 : 1
			}
		}
	}
	
	
	//MARK: - Private Helpers
	
	private func fetchImageForIndex(_ index: Int) {
		if index >= 0, index < self.pages.count, let zoomContainer = self.pages[index] as? UIScrollView, let page = zoomContainer.subviews.first as? RemoteImageView {
			page.fetchImageIfNeeded()
		}
	}
	
	private func clearImageForIndex(_ index: Int) {
		if index >= 0, index < self.pages.count, let zoomContainer = self.pages[index] as? UIScrollView, let page = zoomContainer.subviews.first as? RemoteImageView {
			zoomContainer.setZoomScale(1, animated: false)
			page.clearImage()
		}
	}
	
	private func imageViewInContainer(url: URL?, imageContentMode: UIViewContentMode = .scaleAspectFill) -> UIView {
		let v = RemoteImageView(frame: CGRect(0, 0, 100, 100))
		v.backupImageName = backupImageName
		v.setImageURL(url, fetchImmediately: false, usePlaceholderIfNil: true)
		v.contentMode = imageContentMode
		v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		let zoomContainer = UIScrollView(frame: v.bounds)
		zoomContainer.contentSize = v.bounds.size
		zoomContainer.addSubview(v)
		zoomContainer.delegate = self
		
		return zoomContainer
	}
	
	//MARK: - UIScrollView Delegate
	
	override public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		super.scrollViewDidScroll(scrollView)
		
		if (scrollView != self.scrollView) {
			return
		}
		
		let index = firstVisibleIndex()
		
		for i in 0..<self.pages.count {
			if (i >= index-1 && i <= index+1) {
				fetchImageForIndex(i)
			} else {
				clearImageForIndex(i) // To save memory
			}
		}
	}
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		if (scrollView != self.scrollView), let imageView = scrollView.subviews.first as? RemoteImageView {
			return imageView
		} else {
			return nil
		}
	}
	
	func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
	}
}
