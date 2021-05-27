//
//  MenuOptionsTableViewCell.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-08-27.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import UIKit

class MenuOptionsTableViewCell : UITableViewCell {
	typealias k = Constants.Order
	
	private let titleLabel = UILabel()
	private let instructionsLabel = UILabel()
	private let separator = UIView()
	private var checkGroup : CheckBoxGroup?
	
	weak var delegate : MenuOptionsDelegate?
	
	
	//MARK: - initialization
	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		commonInit()
	}
	
	required init? (coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		setupSeparator()
		setupInstructionsLabel()
		
		type(of:self).setupTitleLabel(titleLabel, parent: self)
	}
	
	//MARK: - private funcs
	
	override func layoutSubviews() {
		super.layoutSubviews()
		separator.frame = CGRect(0,0,self.frame.width, Constants.Menu.separatorHeight)
		
		let titleLabelWidth: CGFloat = self.frame.width - 2*k.leftMargin
		let titleLabelHeight = titleLabel.sizeThatFits(CGSize(titleLabelWidth, 1000)).height
		
		titleLabel.frame = CGRect(k.leftMargin, k.optionTopMargin, self.frame.width - 2*k.leftMargin, titleLabelHeight)
		instructionsLabel.frame = CGRect(k.leftMargin, titleLabel.frame.maxY, titleLabel.frame.width, k.textHeight)
		let checkY = instructionsLabel.frame.maxY + k.optionTopMargin
		checkGroup?.frame = CGRect(k.leftMargin, checkY, self.frame.width - 2*k.leftMargin, frame.height - checkY - k.optionTopMargin)
	}
	
	private func setupSeparator() {
		separator.backgroundColor = .separators
		addSubview(separator)
	}
	
	private class func setupTitleLabel(_ label: UILabel, parent: UIView? = nil) {
		label.textAlignment = .left
		label.font = UIFont.rescounts(ofSize: 17.0)
		label.textColor = .highlightRed
		label.numberOfLines = 0
		label.lineBreakMode = .byTruncatingTail
		
		parent?.addSubview(label)
	}
	
	private func setupInstructionsLabel() {
		instructionsLabel.textAlignment = .left
		instructionsLabel.font = UIFont.lightRescounts(ofSize: 13)
		instructionsLabel.textColor = .lightGrayText
		addSubview(instructionsLabel)
	}
	
	private func setupCheckGroup(forItem item: MenuItemOption, optionIndex : Int) {
		// Get rid of old check box group
		checkGroup?.removeFromSuperview()
		
		let newCheckGroup = CheckBoxGroup(isRadio: true)
		let limits = item.limit ?? 0
		if (limits != 0) {
			newCheckGroup.maxSelected = limits
		}
		
		newCheckGroup.backgroundColor = UIColor.white
		newCheckGroup.showPlusSign = !item.representsBasePrice
		newCheckGroup.showRightLabels = item.hasNonFreeItem()
		newCheckGroup.setOptionStrings(MenuOptionsTableViewCell.converterUI(item: item))
		
		// Set previously selected radio buttons on
		for index in item.selectedIndices {
			newCheckGroup.setOn(true, index: index)
		}
		
		// set up target to the radio button
		let counter = newCheckGroup.getCount()
		for i in 0 ..< counter {
			newCheckGroup.radioButtons[i].addAction(for: .valueChanged, {
				if let value = item.valueForIndex(i) {
					if newCheckGroup.radioButtons[i].on {
						print("I turned on \(value.name)")
						self.delegate?.addOptionItemToList(key: value.name, cost: value.cost, optionID: optionIndex)
					} else {
						print("I turned off \(value.name)")
						self.delegate?.removeOptionItemToList(key: value.name, cost: value.cost, optionID: optionIndex)
					}
				}
			})
		}
		addSubview(newCheckGroup)
		checkGroup = newCheckGroup
		refresh()
	}
	
	
	//MARK: - public funcs
	
	public func refresh() {
        checkGroup?.wakeUp()
	}
	
	public class func converterUI(item: MenuItemOption) -> [(String,String)] {
		let showRightText = item.hasNonFreeItem()
		
		return item.values.map { ($0.name, showRightText ? CurrencyManager.main.getCost(cost: $0.cost) : "") }
	}
	
	//[TITLE:PRICE] FLAG
	public func prepareForMenuOption(_ item: MenuItemOption, optionIndex : Int = 0) {
		
		setupCheckGroup(forItem: item, optionIndex: optionIndex)
		
		titleLabel.text = item.title
		
		instructionsLabel.text = instructionsFor(item.minimum ?? 0, item.limit ?? 0)
		
		addSubview(checkGroup ?? UIView())
				
	}

	public class func getIdealHeight(item: MenuItemOption, cellWidth: CGFloat) -> CGFloat {
		// TODO: we don't want to have to create a UI object to get height, make idealHeight a static method on CheckBoxGroup
		let instantOption = CheckBoxGroup()
		instantOption.setOptionStrings(MenuOptionsTableViewCell.converterUI(item: item))
		instantOption.showPlusSign = !item.representsBasePrice
		instantOption.showRightLabels = item.hasNonFreeItem()
		
		let instantLabel = UILabel()
		setupTitleLabel(instantLabel)
		instantLabel.text = item.title
		
		let titleLabelWidth: CGFloat = cellWidth - 2*k.leftMargin
		let titleLabelHeight = instantLabel.sizeThatFits(CGSize(titleLabelWidth, 1000)).height
		
		return instantOption.idealHeight(width: cellWidth - 2*k.leftMargin) + 3*k.optionTopMargin + 1*k.textHeight + titleLabelHeight
	}
	
	private func instructionsFor(_ minimum: Int, _ limit: Int) -> String {
		if (minimum == 0 && limit == 0) {
			return l10n("optional")
		} else if (minimum == 0 && limit > 0) {
			return /*"Select at most \(limit)"*/ String.localizedStringWithFormat(l10n("selAtMost"), limit)
		} else if (minimum > 0 && limit == minimum) {
			return /*"Select exactly \(limit)"*/ String.localizedStringWithFormat(l10n("selExa"), limit)
		} else if (minimum > 0 && limit > minimum) {
			return /*"Select \(minimum) - \(limit) items"*/ String.localizedStringWithFormat(l10n("selMinLim"), minimum, limit)
		} else {
			return /*"Select at least \(minimum)"*/ String.localizedStringWithFormat(l10n("selAtLeast"), minimum)
		}
	}
}
