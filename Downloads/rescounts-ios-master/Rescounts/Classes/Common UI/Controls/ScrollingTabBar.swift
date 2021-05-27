//
//  ScrollingTabBar.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-09.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class ScrollingTabBar: UIScrollView {
	public var titles: [String] = [] {
		didSet { refreshData() }
	}
	public private(set) var selectedIndex: Int = 0
	public var animDuration = 0.2
	
	private var titleViews: [UIButton] = []
	private var selectionIndicator = UIView()
	private var selectionContainer = UIView()
	
	private let kPadding: CGFloat = 20
	private let kIndicatorHeight: CGFloat = 3
	
	typealias ScrollingTabBarCallback = (ScrollingTabBar) -> Void
	public var didChangeCallback: ScrollingTabBarCallback?
	
	// MARK: - Initialization
	
	convenience init() {
		self.init(frame: CGRect(0, 0, 200, 50)) // Arbitrary size for autoresizing
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
        self.backgroundColor = .white
		self.showsHorizontalScrollIndicator = false
		
		self.selectionIndicator.backgroundColor = .gold
		self.selectionContainer.backgroundColor = .clear
		self.selectionContainer.clipsToBounds = false
		self.selectionContainer.addSubview(self.selectionIndicator)
		addSubview(self.selectionContainer)
	}
	
	
	// MARK: - Public Methods
	
	public func selectSection(_ index: Int, notifyDelegate: Bool = false) {
		if (index != selectedIndex) {
			selectedIndex = index
			
			titleViews.enumerated().forEach { $1.isSelected = ($0 == selectedIndex) }
			
			if 0..<self.titleViews.count ~= selectedIndex {
				UIView.animate(withDuration: animDuration, delay: 0, options: [.curveEaseInOut], animations: {
					self.scrollRectToVisible(CGRect(self.titleViews[index].frame.minX, 0, self.frame.width, self.frame.height), animated: false)
					self.updateSelectedFrame()
				}, completion: nil)
			}
			
			if (notifyDelegate) {
				self.didChangeCallback?(self)
			}
		}
	}
	
	
	// MARK: - Private Helpers
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		var maxX: CGFloat = 0
		titleViews.forEach {
			resizeTitleView($0)
			$0.setX(maxX)
			maxX = $0.frame.maxX
		}
		
		self.contentSize = CGSize(width: maxX, height: frame.height)
		self.selectionContainer.frame = CGRect(0, frame.height - kIndicatorHeight, maxX, kIndicatorHeight)
		
		updateSelectedFrame()
	}
	
	private func refreshData() {
		titleViews.forEach { $0.removeFromSuperview() }
		titleViews.removeAll(keepingCapacity: true)
		
		titles.forEach {
			addViewForTitle($0)
		}
		titleViews.first?.isSelected = true
		
		setNeedsLayout()
	}
	
	private func addViewForTitle (_ title: String) {
		let view = UIButton()
		view.backgroundColor = .clear
		view.setAttributedTitle(RDeals.replaceTitleIn(title.uppercased(), .rDealsDarkR,  size: 28,
                                                      titleAttrs: [.foregroundColor: UIColor.nearBlack], otherAttrs: [.foregroundColor: UIColor.nearBlack]), for: .normal)
		view.setAttributedTitle(RDeals.replaceTitleIn(title.uppercased(), .rDealsLightR, size: 28,
                                                      titleAttrs: [.foregroundColor: UIColor.green, .font: UIFont.rescounts(ofSize: 15.0)],
                                                      otherAttrs: [.foregroundColor: UIColor.white, .font: UIFont.rescounts(ofSize: 15.0)]), for: .selected)
		view.setTitleColor(.nearBlack, for: .normal)
		view.titleLabel?.font = UIFont.lightRescounts(ofSize: 15.0)
		view.addAction(for: .touchUpInside) { [weak self] in
			self?.tappedButton(view)
		}
		addSubview(view)
		titleViews.append(view)
	}
	
	private func resizeTitleView (_ view: UIButton) {
		var newSize = view.sizeThatFits(frame.size)
		newSize = CGSize(width: ceil(newSize.width + 2*kPadding), height: frame.height)
		
		view.frame.size = newSize
	}
	
	private func tappedButton(_ sender: UIButton) {
		selectSection(self.titleViews.index(of: sender) ?? -1, notifyDelegate: true)
	}
	
	private func updateSelectedFrame() {
		if let selectedView = self.titleViews[safe: self.selectedIndex] {
			let titleHeight = selectedView.frame.height - kIndicatorHeight
			let kTopMargin: CGFloat = 10
			let kSideMargin: CGFloat = 3
			self.selectionIndicator.frame = CGRect(selectedView.frame.minX + kSideMargin, -titleHeight + kTopMargin, selectedView.frame.width - 2*kSideMargin, selectedView.frame.height - 2*kTopMargin)//kIndicatorHeight)
			self.selectionIndicator.layer.cornerRadius = (selectedView.frame.height-20)/2
		} else {
			self.selectionIndicator.frame = .zero
		}
        
//        for index in 0...self.titleViews.count - 1 {
//            if index != self.selectedIndex {
//                let selectedView =  titleViews[index]
//                let titleHeight = selectedView.frame.height - kIndicatorHeight
//                     let kTopMargin: CGFloat = 10
//                     let kSideMargin: CGFloat = 3
//                     self.selectionIndicator.frame = CGRect(selectedView.frame.minX + kSideMargin, -titleHeight + kTopMargin, selectedView.frame.width - 2*kSideMargin, selectedView.frame.height - 2*kTopMargin)//kIndicatorHeight)
//                self.selectionIndicator.backgroundColor = .blue
//                     self.selectionIndicator.layer.cornerRadius = (selectedView.frame.height-20)/2
//                 } else {
//                     self.selectionIndicator.frame = .zero
//                 }
//            }
        }
    
}
