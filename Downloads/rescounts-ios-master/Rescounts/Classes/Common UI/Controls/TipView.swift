//
//  TipButton.swift
//  Rescounts
//
//  Created by Kittiphong Xayasane on 2018-08-19.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class TipView: UIControl {
    private let tipLabel = UILabel()
	public var tipAmount: Float? = 0.0
    private let topSeparator = UIView()
    private let bottomSeparator = UIView()
    private let kTipLabelFontSize = 20
    private let kSeparaterHeight = 2.0
    public var isTipSelected = false {
        didSet { update() }
    }
    
    //MARK: - Initialization
    
	convenience init(text: String, tipAmount: Float?) {
		self.init(frame: CGRect(0.0, 0.0, 30.0, 30.0), text: text, tipAmount: tipAmount)
    }
    
	init(frame: CGRect, text: String, tipAmount: Float?) {
		super.init(frame: frame)
		commonInit(text: text, tipAmount: tipAmount)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Private Methods
    
	private func commonInit(text: String = "", tipAmount: Float? = nil) {
		self.tipAmount = tipAmount
        self.backgroundColor = UIColor.lighterGray
        
        tipLabel.text = text
        tipLabel.font = UIFont.rescounts(ofSize: CGFloat(kTipLabelFontSize))
        tipLabel.textColor = .dark
        addSubview(tipLabel)
        
        
        
        topSeparator.backgroundColor = UIColor.separators
        addSubview(topSeparator)
    
        bottomSeparator.backgroundColor = UIColor.separators
        addSubview(bottomSeparator)
    }
    
    private func update() {
        topSeparator.isHidden = isTipSelected
        bottomSeparator.isHidden = isTipSelected
        
        if isTipSelected {
            backgroundColor = UIColor.gold
        } else {
            backgroundColor = UIColor.lighterGray
        }
        setNeedsLayout()
    }
    
    // MARK: - UIView Methods
    
    override func layoutSubviews() {
        let tipLabelWidth = tipLabel.text?.width(withConstrainedHeight: frame.height, font: .rescounts(ofSize: CGFloat(kTipLabelFontSize))) ?? 0
        let tipLabelHeight = tipLabel.text?.height(withConstrainedWidth: frame.width, font: .rescounts(ofSize: CGFloat(kTipLabelFontSize))) ?? 0
        
        tipLabel.frame = CGRect(self.frame.width/2 - tipLabelWidth/2, self.frame.height/2 - tipLabelHeight/2, tipLabelWidth, tipLabelHeight)
        topSeparator.frame = CGRect(0.0, 0.0, frame.width, CGFloat(kSeparaterHeight))
        bottomSeparator.frame = CGRect(0.0, frame.height - CGFloat(kSeparaterHeight), frame.width, CGFloat(kSeparaterHeight))
    }

}
