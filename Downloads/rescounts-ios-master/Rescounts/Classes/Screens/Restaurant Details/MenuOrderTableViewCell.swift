//
//  MenuOrderTableViewCell.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-08-16.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import UIKit

enum MenuItemType{
	case confirmed, pending
}

class MenuOrderTableViewCell: UITableViewCell {
	typealias k = Constants.Order
	
	private let titleLabel = UILabel()
	private let descrLabel = UILabel()
    private let priceLabel = UILabel()
	let separatorLine = UIView()
	private let trashButton = UIButton(type: .custom)
    private let editButton = UIButton(type: .custom)

	weak var delegate: MenuOrderTableViewCellDelegate?
	
	static let kTrashSize: CGFloat = 30
	
	private var type : MenuItemType = MenuItemType.confirmed
	
	private var orderItem: OrderItem? = nil
	
	private let optionsListPriceInst = UILabel()
	
	// MARK: - Initialization
	
	let width : CGFloat = 150
	let leftMargin : CGFloat = 25
	let footer : CGFloat = 25
	let titleFont : CGFloat = 15
	private var receiptLength : CGFloat  = 0
	
	
	
	override init (style: UITableViewCellStyle, reuseIdentifier: String?){
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		commonInit()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		commonInit()
	}
	private func commonInit(){
		addSubview(titleLabel)
		addSubview(descrLabel)
        addSubview(priceLabel)
		addSubview(separatorLine)
		addSubview(trashButton)
        addSubview(editButton)
		addSubview(optionsListPriceInst)
		
		setUpTrashButton()
        setupEditButton()
        NotificationCenter.default.addMainObserver(forName: .startedNewOrder,   owner: self, action: MenuOrderTableViewCell.orderStateChanged)

	}
	
	
	// MARK: - Private Helpers
	
	private func setupLabel(_ label: UILabel, font: UIFont, text: String? = "", numLines: Int = 1, alignment: NSTextAlignment = .left) {
		label.backgroundColor = .clear
		label.textColor = .dark
		label.font = font
		label.textAlignment = alignment
		label.text = text
		label.numberOfLines = numLines
	}
	
	private func setUpTrashButton() {
		let image = UIImage(named: "iconDelete")
        
        let tintedImage = image?.withRenderingMode(.alwaysTemplate)
		trashButton.setImage(tintedImage, for: .normal)
        trashButton.tintColor = .gold

		trashButton.setBackgroundImage(UIImage(color: .clear), for: .normal)
		trashButton.layer.masksToBounds = true
		
		trashButton.addAction(for: .touchUpInside, { [weak self] in
			if OrderManager.main.isPolling {
				RescountsAlert.showAlert(title: l10n("deleteMenuErrorTitle"), text: l10n("deleteMenuErrorText"))
				
			} else if let strongSelf = self, let orderItem = strongSelf.orderItem {
				strongSelf.delegate?.MenuOrderRemoveOrderItem(strongSelf, orderItem)
				strongSelf.delegate?.MenuOrderDidTapTrash(strongSelf)
			}
		})
	}
    
    func setupEditButton() {
        let image = UIImage(named: "editIcon")
        let tintedImage = image?.withRenderingMode(.alwaysTemplate)
            editButton.setImage(tintedImage, for: .normal)
            editButton.tintColor = .gold
        
        editButton.setBackgroundImage(UIImage(color: .clear), for: .normal)
        editButton.layer.masksToBounds = true
        
        editButton.addAction(for: .touchUpInside, { [weak self] in
            if OrderManager.main.isPolling {
                RescountsAlert.showAlert(title: l10n("deleteMenuErrorTitle"), text: l10n("deleteMenuErrorText"))
                
            } else if let strongSelf = self, let orderItem = strongSelf.orderItem {
                strongSelf.delegate?.MenuOrdeEditOrderItem(strongSelf, orderItem)
                strongSelf.delegate?.MenuOrderDidTapEdit(strongSelf)
            }
        })
    }
	
	private func setupSeparators() {
		separatorLine.backgroundColor = .separators
	}
	
	private func get2Digit( value : Float) -> String{
		return String(format:"%.2f", value)
	}
	
	//TODO: change the value type to [String : [String]]
	private static func getOptionsString(item:MenuItem) -> String {
		
		var result : [String: [String]] = [:]
		for singleItem in item.options ?? [] {
			result[singleItem.title] = singleItem.selectedNames()
		}
		
		return convertOptionslistToString(item: result)
		
	}
	
	private static func convertOptionslistToString(item: [String : [String]]) -> String {
		var result = ""
		for singleItem in item {
			if let values = item[singleItem.key], values.count > 0 {
				/*result = result + singleItem.key +  "\n"*/
				result = result + (item[singleItem.key] ?? []).joined(separator: ", ") + "\n"
			}
		}
		return String(result.dropLast())
	}
	
	private static func descriptionTextForItem(_ menuItem: MenuItem) -> String {
		var descriptText = "\(getOptionsString(item: menuItem))"
		if (menuItem.requests != "") {
			descriptText += "\(descriptText.count > 0 ? "\n" : "")\(l10n("notes"))\n\(menuItem.requests)"
		}
		return descriptText
	}
	
	private static func shouldShowOptionsInfoLabel(_ menuItem: MenuItem) -> Bool {
        typealias MenuItemOptionValue = (name: String, cost: Int)
        var result : [String: [MenuItemOptionValue]] = [:]

		for singleItem in menuItem.options ?? [] {
            result[singleItem.title] = singleItem.selectedValues()
		}
		for singleItem in result {
            if let values = result[singleItem.key], values.count > 0 {
                
                for value in values {
                    if value.cost > 0 {
                       return true
                    }
                }
				
                
                
                
			}
		}
		
		return false
		
	}
	
	
	// MARK: - Public Helpers
	public class func heightForItem(_ item: MenuItem, confirmed: Bool, width cellWidth: CGFloat) -> CGFloat {

		let titleLabel: UILabel = UILabel()
		titleLabel.text = item.title
		titleLabel.numberOfLines = 0
		titleLabel.font = UIFont.rescounts(ofSize: 15)
		
		let priceLabel: UILabel = UILabel()
        priceLabel.text = CurrencyManager.main.getCost(cost: item.getSubtotal(isRDeal: item.rDealsPrice != nil) )
		priceLabel.numberOfLines = 0
		priceLabel.font = UIFont.rescounts(ofSize: 15)
		
		let priceWidth = floor(priceLabel.sizeThatFits(CGSize(200, 100)).width) + 5
		
		let titleLabelWidth: CGFloat = cellWidth - (25 * 2) - priceWidth - k.spacer
		let titleLabelHeight = titleLabel.sizeThatFits(CGSize(titleLabelWidth, 1000)).height
		
		let descrLabel: UILabel = UILabel()
		descrLabel.text = descriptionTextForItem(item)
		descrLabel.numberOfLines = 0
		descrLabel.font = UIFont.lightRescounts(ofSize: k.detailFontSize)
		let textHeight = descrLabel.sizeThatFits(CGSize(cellWidth/2 + 40, 1000)).height
		
		let optionsInfoLabel: UILabel = UILabel()
		optionsInfoLabel.text = l10n("optionsListPriceInst")
		optionsInfoLabel.numberOfLines = 0
		optionsInfoLabel.font = UIFont.lightRescounts(ofSize: k.detailFontSize - 2)
		let showOptions = shouldShowOptionsInfoLabel(item)
		let optionsInfoLabelHeight = showOptions ? (optionsInfoLabel.sizeThatFits(CGSize(cellWidth/2 + 40, 1000)).height + k.spacer * 2) : 0.0
		
		if textHeight != 0 {
			return k.cellPaddingTop + titleLabelHeight + k.spacer + textHeight + optionsInfoLabelHeight + k.cellPaddingTop - k.reducedSpace
		} else {
			let leftHeight  = k.cellPaddingTop + titleLabelHeight + k.spacer + optionsInfoLabelHeight + (k.cellPaddingTop  - k.reducedSpace)
			let rightHeight = k.cellPaddingTop + k.textHeight + k.spacer + (confirmed ? 0 : kTrashSize) + (k.cellPaddingTop - k.reducedSpace)
			return max(leftHeight, rightHeight)
		}
	}

	public func setSeparatorShowing(_ isShowing: Bool) {
		separatorLine.isHidden = !isShowing
	}
	
	public func prepareForOrderItem(_ orderItem: OrderItem, _ confirmed: Bool = true) {
		self.orderItem = orderItem
		self.prepareForMenuItem(orderItem.getItem(), orderItem.getNum(), confirmed)
	}

	public func prepareForMenuItem(_ menuItem : MenuItem, _ num: Int  = 1, _ confirmed: Bool = true){
		
		var title : String = menuItem.title
		if(num > 1) {
			title = "\(num)x \(menuItem.title)"
		}
		
        let price = menuItem.getSubtotal(isRDeal: menuItem.rDealsPrice != nil) * num
		setupLabel(titleLabel, font: UIFont.rescounts(ofSize: titleFont), text: title, numLines: 0)
		setupLabel(descrLabel, font: UIFont.lightRescounts(ofSize: k.detailFontSize), text: MenuOrderTableViewCell.descriptionTextForItem(menuItem), numLines: 0)
		setupLabel(priceLabel, font: UIFont.rescounts(ofSize: titleFont), text: CurrencyManager.main.getCost(cost: price), numLines: 0, alignment: .right)
		setupLabel(optionsListPriceInst, font: UIFont.lightRescounts(ofSize: k.detailFontSize - 2), text: l10n("optionsListPriceInst"), numLines: 0, alignment: .left)
		setupSeparators()
		
		let descriptionWidth: CGFloat = self.frame.width/2 + MenuOrderTableViewCell.kTrashSize
		let descriptionHeight = descrLabel.sizeThatFits(CGSize(descriptionWidth, 1000)).height
		let optionsHeight = optionsListPriceInst.sizeThatFits(CGSize(descriptionWidth, 1000)).height
		
		let priceWidth = floor(priceLabel.sizeThatFits(CGSize(200, 100)).width) + 5
		
        priceLabel.frame = CGRect(self.frame.width - priceWidth - leftMargin, k.cellPaddingTop, priceWidth, k.textHeight)
		
		let titleLabelWidth: CGFloat = self.frame.width - (leftMargin * 2) - priceLabel.frame.width - k.spacer
		let titleLabelHeight = titleLabel.sizeThatFits(CGSize(titleLabelWidth, 1000)).height
		
		titleLabel.frame = CGRect(leftMargin, k.cellPaddingTop, titleLabelWidth, titleLabelHeight)
		descrLabel.frame = CGRect(leftMargin, titleLabel.frame.maxY + k.spacer, descriptionWidth, descriptionHeight)
		optionsListPriceInst.frame = CGRect(leftMargin, descrLabel.frame.maxY + k.spacer * 2, descriptionWidth, optionsHeight)
		
		if (MenuOrderTableViewCell.shouldShowOptionsInfoLabel(menuItem)) {
			optionsListPriceInst.isHidden = false
		} else {
			optionsListPriceInst.isHidden = true
		}
		
		if confirmed { // When the menu has been confirmed, turn all color to be gray
			turnToConfirmed()
			trashButton.isHidden = true
            editButton.isHidden = true
			
		} else {
		   type = MenuItemType.pending
		   trashButton.isHidden = OrderManager.main.isPolling ? true : false
            editButton.isHidden = OrderManager.main.isPolling ? true : false
		}
		priceLabel.textColor = (price < menuItem.price) ? .primary : confirmed ? .lightGray : .dark
	}

    private func orderStateChanged(_ notification: Notification?) {
        trashButton.isHidden = true
         editButton.isHidden = true
    }
	public func removeTrashButton(){
		trashButton.isHidden = true
        editButton.isHidden = true
	}
	
	public func getType () -> MenuItemType{
		return self.type
	}
	
	public func turnToConfirmed () {
		titleLabel.textColor = .lightGray
		descrLabel.textColor = .lightGray
		priceLabel.textColor = .lightGray
		optionsListPriceInst.textColor = .lightGray
		type = MenuItemType.confirmed
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		trashButton.frame = CGRect(self.frame.width - leftMargin - MenuOrderTableViewCell.kTrashSize + 10,
								   k.cellPaddingTop + k.textHeight + k.spacer,
								   MenuOrderTableViewCell.kTrashSize,
								   MenuOrderTableViewCell.kTrashSize)
        
        
        
        editButton.frame = CGRect(self.frame.width - leftMargin - MenuOrderTableViewCell.kTrashSize - 30,
                                   k.cellPaddingTop + k.textHeight + k.spacer,
                                   MenuOrderTableViewCell.kTrashSize,
                                   MenuOrderTableViewCell.kTrashSize)
		separatorLine.frame = CGRect(0, 0, self.frame.width, Constants.Menu.separatorHeight)
	}
	
}
