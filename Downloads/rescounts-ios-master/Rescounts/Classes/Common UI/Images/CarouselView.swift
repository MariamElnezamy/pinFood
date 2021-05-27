//
//  CarouselView.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-27.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//
//	A paging scrollview that only uses gestures -- does not track user drags directly.

import UIKit

class CarouselView: UIView, UIScrollViewDelegate {
	
	internal let scrollView = UIScrollView()
	internal var pages: [UIView] = [] {
		didSet { updatePages() }
	}
	
	public var showPageIndicator = true {
		didSet { updatePageIndicator() }
	}
	
	internal var usingPlaceholder = false
	
	private let pageIndicator = UILabel()
	private let kPageIndicatorSize = CGSize(width: 70.0, height: 26.0)
	
	public internal(set) var currentIndex = 0 {
		didSet {
			updatePageIndicator()
		}
	}
	
	
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
		scrollView.frame = self.bounds
		scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		addSubview(scrollView)
		
		self.scrollView.isPagingEnabled = true
		self.scrollView.delegate = self
		self.scrollView.alwaysBounceVertical = false
		
		setupPageIndicator()
		updatePageIndicator()
	}
	
	
	//MARK: - Private Helpers
	
	private func updatePages() {
		self.scrollView.contentSize = CGSize(width: frame.width * CGFloat(pages.count), height: frame.height)
		
		self.scrollView.subviews.forEach({ $0.removeFromSuperview() })
		
		for i in 0..<self.pages.count {
			let page = self.pages[i]
//			page.frame = CGRect(CGFloat(i) * frame.width, 0.0, frame.width, frame.height)
			self.scrollView.addSubview(page)
		}
		
		updatePageIndicator()
		setNeedsLayout()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.scrollView.contentSize = CGSize(width: bounds.width * CGFloat(pages.count), height: bounds.height)
		
		for i in 0..<self.pages.count {
			let page = self.pages[i]
			page.frame = CGRect(CGFloat(i) * bounds.width, 0.0, bounds.width, bounds.height)
		}
		
		self.pageIndicator.frame = CGRect(floor((bounds.width - kPageIndicatorSize.width) / 2), bounds.height - kPageIndicatorSize.height - 10.0, kPageIndicatorSize.width, kPageIndicatorSize.height)
		self.pageIndicator.layer.cornerRadius = kPageIndicatorSize.height / 2
		
		scrollToX(CGFloat(currentIndex) * frame.width, animated: false)
	}
	
	private func scrollToX(_ x: CGFloat, animated: Bool = true) {
		self.scrollView.scrollRectToVisible(CGRect(x, 0, frame.size.width, frame.size.height), animated: animated)
	}
	
	internal func firstVisibleIndex() -> Int {
		return Int(scrollView.contentOffset.x / bounds.width)
	}
	
	private func setupPageIndicator() {
		self.pageIndicator.textColor = .white
		self.pageIndicator.backgroundColor = UIColor(white: 0.15, alpha: 0.7)
		self.pageIndicator.layer.masksToBounds = true
		self.pageIndicator.textAlignment = .center
		self.pageIndicator.font = UIFont.rescounts(ofSize: 13.0)
		self.pageIndicator.adjustsFontSizeToFitWidth = true
		
		self.addSubview(self.pageIndicator)
	}
	
	private func updatePageIndicator() {
		self.pageIndicator.text = "\(1 + currentIndex) of \(self.pages.count)"
		self.pageIndicator.isHidden = (self.pages.count == 0 || !showPageIndicator || usingPlaceholder)
	}
	
	
	//MARK: - UIScrollView Delegate
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
	}
	
	public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		if (scrollView != self.scrollView) {
			return
		}
		currentIndex = Int((scrollView.contentOffset.x + 0.001) / bounds.width)
	}
}
