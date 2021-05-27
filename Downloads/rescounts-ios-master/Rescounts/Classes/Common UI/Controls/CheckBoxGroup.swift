//
//  CheckBoxGroup.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-30.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class CheckBoxGroup: UIView {
	
	private var options: [(left: String, right: String)] = []
	var radioButtons: [CheckBox] = []
	private var isRadioButtons = false
	
	let kRowHeight: CGFloat = 20
	let kSpacer: CGFloat = 12

	private var selectedIndices : [Bool] = []
	private var numSelected: Int {
		var retVal: Int = 0
		selectedIndices.forEach { retVal += $0 ? 1 : 0 }
		return retVal
	}
	
	public private(set) var allowMultiLine = false
	
	public var maxSelected: Int = 1
	
	public var showRightLabels = true
	
	// TODO: This doesn't belong in 'CheckBoxGroup', it should be in the owning VC or view -- this class just cares about left text and right text
	public var showPlusSign = false
	
	public var selectedIndex: Int {
		assert(maxSelected == 1)
		return firstSelectedIndex()
	}
	
	
	// MARK: - Initialization
	
	init(isRadio: Bool = false) {
		super.init(frame: .arbitrary)
		commonInit(isRadio: isRadio)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit(isRadio: Bool = false) {
		isRadioButtons = isRadio
	}
	
	
	// MARK: - Public Methods
	
	public func wakeUp(){
		for button in radioButtons {
			button.wakeUp()
		}
	}
	
	public func goSleep() {
		for button in radioButtons {
			button.goSleep()
		}
	}
	
	public func setOptionStrings(_ optionsStrings: [String]) {
		setOptionStrings(optionsStrings.map { ($0, "") })
	}
	
	public func setOptionStrings(_ optionsStrings: [(String,String)]) {
		options = optionsStrings
		selectedIndices = [Bool](repeating: false, count: options.count)
		ensureCheckboxesSelectionStyle()
		refreshButtons()
	}
	
	public func setOn(_ isOn: Bool, index: Int) {
		if (0..<options.count ~= index) {
			
			// First check we're not at max already
			if (isOn && !self.selectedIndices[index] && numSelected == maxSelected) {
				turnOffFirstIndex()
			}
			
			// Then update our data
			self.selectedIndices[index] = isOn
		}
		updateButtonStates()
	}
	
	public func isOn(index: Int) -> Bool {
		if (0..<options.count ~= index) {
			return radioButtons[index].on
		} else {
			return false
		}
	}
	
	public func setTextColor(color: UIColor) {
		for button in radioButtons {
			button.setTextColor(color: color)
		}
	}
	
	public func idealHeight() -> CGFloat {
		allowMultiLine = false // If they're asking for height without width, they're assuming single-line options
		return CGFloat(options.count) * kRowHeight + CGFloat(max(0,options.count - 1)) * kSpacer
	}
	
	public func idealHeight(width: CGFloat) -> CGFloat {
		allowMultiLine = true // If they're asking for height with width, they're assuming options can wrap
		
		var retVal = CGFloat(max(0,options.count - 1)) * kSpacer
		
		for (key, val) in options {
			retVal += CheckBox.heightFor(text1: key, text2: "\(showPlusSign ? "+" : "")\(val)", width: width, lineHeight: kRowHeight)
		}
		return retVal
	}
	
	public func setButtonType (isRadio: Bool) {
		isRadioButtons = isRadio
		ensureCheckboxesSelectionStyle()
		refreshButtons()
	}
	
	public func getCount() -> Int {
		return radioButtons.count
	}
	
	
	// MARK: - UIView Methods
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		if allowMultiLine {
			for (i, button) in radioButtons.enumerated() {
				button.frame = CGRect(0, CGFloat(i)*(kSpacer + kRowHeight), frame.width, kRowHeight)
				button.allowMultiline(false)
			}
		} else {
			var y: CGFloat = 0
			for button in radioButtons {
				button.frame = CGRect(0, y, frame.width, button.idealHeight(width: frame.width))
				button.allowMultiline(true)
				y += button.frame.height + kSpacer
			}
		}
	}
	
	
	// MARK: - Private Helpers
	
	private func refreshButtons() {
		radioButtons.forEach {
			$0.removeFromSuperview()
		}
		radioButtons.removeAll(keepingCapacity: true)
		
		for (index, option) in options.enumerated() {
			let b = CheckBox(text: option.left, text2: showRightLabels ? "\(showPlusSign ? "+" : "")\(option.right)" : "", isRadio: isRadioButtons)
			radioButtons.append(b)
			b.lineHeight = kRowHeight
			b.groupIndex = index
			addSubview(b)
			
			b.addAction(for: .valueChanged) { [weak self] in
				self?.setOn(b.on, index: b.groupIndex)
			}
		}
		
		updateButtonStates();
	}
	
	private func updateButtonStates() {
		for (i, button) in radioButtons.enumerated() {
			button.on = self.selectedIndices[i]
		}
	}
	
	private func turnOffFirstIndex() {
		for i in 0..<selectedIndices.count {
			if (self.selectedIndices[i]) {
				self.selectedIndices[i] = false
				return
			}
		}
	}
	
	private func firstSelectedIndex() -> Int {
		for i in 0..<selectedIndices.count {
			if (self.selectedIndices[i]) {
				return i
			}
		}
		return -1
	}
	
	private func ensureCheckboxesSelectionStyle() {
		if (!isRadioButtons && options.count > 0) {
			maxSelected = options.count
		}
	}
}
