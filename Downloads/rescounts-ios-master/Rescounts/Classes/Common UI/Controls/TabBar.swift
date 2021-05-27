//
//  TabBar.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2019-05-31.
//  Copyright © 2019 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class TabBar: UIControl {
	
	public private(set) var selectedIndex: Int = 0;
	
	private var buttons: [UIButton] = []
	private let footer = UIView()
	
	private let kFooterHeight: CGFloat = 2

	// MARK: - Setup
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		backgroundColor = .white
		
		footer.backgroundColor = .primary
		addSubview(footer)
	}
	
	
	// MARK: - UIControl Methods
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let buttonWidth = floor(frame.width / CGFloat(max(1, buttons.count)))
		for (i, button) in buttons.enumerated() {
			button.frame = CGRect(CGFloat(i)*buttonWidth, 0, buttonWidth, frame.height - kFooterHeight)
		}
		
		// Fix last button to fill rest of width
		if let b = buttons.last {
			b.setWidth(frame.width - b.frame.minX)
		}
		
		footer.frame = CGRect(0, frame.height - kFooterHeight, frame.width, kFooterHeight)
	}
	
	
	// MARK: - Public Methods
	
	public func setTitles(_ newTitles: [(normal: NSAttributedString, selected: NSAttributedString?)]) {
		recreateButtons(newTitles)
	}
	
	
	// MARK: - Private Helpers

	private func recreateButtons(_ newTitles: [(normal: NSAttributedString, selected: NSAttributedString?)]) {
		buttons.forEach { $0.removeFromSuperview() }
		buttons.removeAll()
		
		for (i, title) in newTitles.enumerated() {
			addButton(i, title.normal, title.selected)
		}
		
		selectedIndex = 0
		buttons.first?.isSelected = true
		
		setNeedsLayout()
	}
	
	private func addButton(_ index: Int, _ title: NSAttributedString, _ selectedTitle: NSAttributedString?) {
		let butt = UIButton()
		
		butt.setAttributedTitle(titleWithColor(title, color: .dark), for: .normal)
		butt.setAttributedTitle(titleWithColor(selectedTitle ?? title, color: .white), for: .selected)
		butt.setBackgroundImage(nil, for: .normal)
		butt.setBackgroundImage(UIImage(color: .primary), for: .selected)
		
		butt.addAction(for: .touchUpInside) { [weak self] in
			self?.tappedButton(index)
		}
		
		addSubview(butt)
		buttons.append(butt)
	}
	
	private func tappedButton(_ index: Int) {
		print("Tapped button: \(index)")
		for button in buttons {
			button.isSelected = false
		}
		buttons[index].isSelected = true
		
		if (index != selectedIndex) {
			selectedIndex = index
			self.sendActions(for: .valueChanged)
		}
	}
	
	private func titleWithColor(_ title: NSAttributedString, color: UIColor) -> NSAttributedString {
		guard let newTitle = title.mutableCopy() as? NSMutableAttributedString else {
			return title
		}
		
		newTitle.addAttribute(.foregroundColor, value: color, range: NSMakeRange(0, title.string.count))
		
		return newTitle
	}
}
