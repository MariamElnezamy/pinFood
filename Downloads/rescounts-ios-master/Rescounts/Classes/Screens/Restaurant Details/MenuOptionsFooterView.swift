//
//  MenuOptionsFooterView.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-08-27.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import UIKit

class MenuOptionsFooterView: UIView, UITextViewDelegate {
	typealias k = Constants.Order
	typealias kMenu = Constants.Menu
	
	private let placeholder = UILabel()
	private let mainTextView = UITextView()
	private let textViewHeight : CGFloat = 100
	private let separator = UIView()
	private let separator2 = UIView()
	private let addToOrderButton = RescountsButton()
	private let buttonView = UIView()
	private let numberLabel = UILabel()
	public  let numberTextView = UITextField()
	private let upButton = RescountsButton()
	private let downButton = RescountsButton()
	
	private var totalPrice : Int = 0
	private let spacer : CGFloat = 7
	private let kButtonLeftMargin : CGFloat = 60.0
	private let kButtonHeight : CGFloat = 50.0
	
	public var numItems: Int {
		return Int(numberTextView.text ?? "1") ?? 1
	}
	
	weak var delegate: MenuOptionsDelegate?
	
	// MARK: Initialization
	
	init(frame: CGRect, price: Int, restaurant: Restaurant?) {
		super.init(frame: frame)
		commonInit(price: price, restaurant: restaurant)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit(price: 0)
	}
	
	
	private func commonInit(price : Int, restaurant: Restaurant? = nil) {
		
		mainTextView.delegate = self
		mainTextView.backgroundColor = .white
		placeholder.textAlignment = .left
		placeholder.text = l10n("sub&allerText")
		placeholder.font = UIFont.lightRescounts(ofSize: 12)
		placeholder.numberOfLines = 0
		placeholder.textColor = UIColor.gray
		mainTextView.addSubview(placeholder)
		placeholder.isHidden = !mainTextView.text.isEmpty
		separator.backgroundColor = UIColor.separators
		separator2.backgroundColor = UIColor.separators
		
		self.totalPrice = price
		refresh(restaurant: restaurant)
		addToOrderButton.setTitleColor(.dark, for: .normal)
		addToOrderButton.titleLabel?.font = UIFont.rescounts(ofSize: 16)

		addToOrderButton.addAction(for: .touchUpInside, { [weak self] in
			print("Clicked add to order button")
			if let strongSelf = self {
				strongSelf.delegate?.clickedAddToOrderButton( strongSelf, strongSelf.mainTextView.text)
			}

		})
		
		buttonView.backgroundColor = .white
		
		addSubview(separator)
		addSubview(mainTextView)
		addSubview(separator2)
		
		setupNumberLabel()
		setupNumberTextView()
		setupArrowButtons()
		
		buttonView.addSubview(addToOrderButton)
	}

	// MARK: - UITextView setup
	
	func textViewDidChange(_ textView: UITextView) {
		placeholder.isHidden = !mainTextView.text.isEmpty
		if (!mainTextView.text.isEmpty){
			mainTextView.font = UIFont.rescounts(ofSize: 15)
			mainTextView.textColor = UIColor.dark
		}
	}

	
	// MARK: - private funcs
	
	private func get2Digit( value : Float) -> String{
		return String(format:"%.2f", value)
	}
	
	private func setupNumberLabel() {
		numberLabel.backgroundColor = .clear
		numberLabel.textColor = .dark
		numberLabel.font = UIFont.lightRescounts(ofSize: 15)
		numberLabel.text = l10n("numItems")
	
		
		addSubview(numberLabel)
	}
	
	private func setupNumberTextView() {
		numberTextView.backgroundColor = .clear
		numberTextView.textColor = .dark
		numberTextView.font = UIFont.lightRescounts(ofSize: 15)
		numberTextView.textAlignment = .center
		numberTextView.text = "1"
		numberTextView.keyboardType = .numberPad
		numberTextView.borderStyle = .roundedRect
		
		addSubview(numberTextView)
	}
	
	private func setupArrowButtons () {
		upButton.setTitle("+", for: .normal)
		upButton.titleLabel?.font = UIFont.rescounts(ofSize: 15.0)
		upButton.isUserInteractionEnabled = true
		upButton.addAction(for: UIControlEvents.touchUpInside) { [weak self] in
			self?.tappedIncrement()
		}
		
		addSubview(upButton)
		
		downButton.setTitle("-", for: .normal)
		downButton.titleLabel?.font = UIFont.rescounts(ofSize: 15.0)
		downButton.isUserInteractionEnabled = true
		downButton.addAction(for: UIControlEvents.touchUpInside) { [weak self] in
			self?.tappedDecrement()
		}
		
		addSubview(downButton)
	}
	
	private func tappedIncrement() {
		numberTextView.text = String(numItems + 1)
		NotificationCenter.default.post(name: .UITextFieldTextDidChange, object: numberTextView)
	}
	
	private func tappedDecrement() {
		if (numItems - 1) > 0 {
			numberTextView.text = String(numItems - 1)
			NotificationCenter.default.post(name: .UITextFieldTextDidChange, object: numberTextView)
		}
	}
	
	
	// MARK: - layout frame
	
	override func layoutSubviews() {
		super.layoutSubviews()
		separator.frame = CGRect(0,0,self.frame.width, kMenu.separatorHeight)
		placeholder.frame = CGRect(8,5,self.frame.width - (k.leftMargin * 2.0), k.textHeight)
		mainTextView.frame = CGRect(k.leftMargin,  k.cellPaddingTop, self.frame.width - k.leftMargin * 2, textViewHeight)
		separator2.frame = CGRect(0, mainTextView.frame.maxY + spacer, self.frame.width, kMenu.separatorHeight)
		
		let textWidth = numberLabel.text?.width(withConstrainedHeight: k.textHeight, font: numberLabel.font) ?? 0
		numberLabel.frame = CGRect(k.leftMargin, separator2.frame.maxY + 12 + floor(0.5*k.textHeight), textWidth, k.textHeight)
		downButton.frame = CGRect(numberLabel.frame.maxX + 10, numberLabel.frame.minY - floor(0.5*k.textHeight), 2*k.textHeight, 2*k.textHeight)
		numberTextView.frame = CGRect(downButton.frame.maxX + 10, numberLabel.frame.minY, 40, k.textHeight)
		upButton.frame = CGRect(numberTextView.frame.maxX + 10, downButton.frame.minY, 2*k.textHeight, 2*k.textHeight)
		
		upButton.layer.cornerRadius = upButton.frame.width / 2
		downButton.layer.cornerRadius = downButton.frame.width / 2
		
		let width = self.frame.width - (kButtonLeftMargin * 2)
		addToOrderButton.frame = CGRect(kButtonLeftMargin,/*separator2.frame.maxY + k.cellPaddingTop */ 10.0, width, kButtonHeight)
		delegate?.setupAddToOrderButton(buttonView)
	}
	
	// MARK: - public funcs
	
	public func getIdealHeight (restaurant: Restaurant) -> CGFloat {
		let numberHeight = OrderManager.main.canAddTo(restaurant) ? 2*k.textHeight : 0
		return k.cellPaddingTop * 3 + textViewHeight + spacer + kMenu.separatorHeight + kButtonHeight + numberHeight
	}
	
	public func updateTotalPrice (price: Int) {
		self.totalPrice = price
		addToOrderButton.setTitle("\(l10n("addToOrder").uppercased())   \(CurrencyManager.main.getCost(cost: Int(price)))", for: .normal)
	}
	
    public func refresh(restaurant: Restaurant?,numberofItems:Int = 1) {
		let canAdd = OrderManager.main.canAddTo(restaurant)
		
		mainTextView.isUserInteractionEnabled = canAdd
		mainTextView.isHidden = !canAdd
		placeholder.isHidden = !canAdd
		separator2.isHidden = !canAdd
//		numberLabel.isHidden = !canAdd
//		numberTextView.isUserInteractionEnabled = canAdd
//		numberTextView.isHidden = !canAdd
//		upButton.isHidden = !canAdd
//		downButton.isHidden = !canAdd
        numberTextView.text = "\(numberofItems)"
        
		if (!canAdd) {
			addToOrderButton.setTitle(l10n("addToOrder").uppercased(), for: .normal)
		} else {
			addToOrderButton.setTitle("\(l10n("addToOrder").uppercased())   \(CurrencyManager.main.getCost(cost: self.totalPrice * numberofItems))", for: .normal)
		}
	}
}
