//
//  TipButtonGroup.swift
//  Rescounts
//
//  Created by Kittiphong Xayasane on 2018-08-19.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class TipGroup: UIView {
	public var tipViews: [TipView] = [TipView(text: l10n("15%") , tipAmount: 0.15),
                                       TipView(text: l10n("18%"), tipAmount: 0.18),
                                       TipView(text: l10n("20%"), tipAmount: 0.20),
									   TipView(text: l10n("currencySign"), tipAmount: 0.00)]

	public var selectedIndex: Int? {
		didSet { update() }
	}
	public var tappedActionCallback: ((Float?, Bool) -> ())?

    // MARK: Initialization
    
    init() {
        super.init(frame: .arbitrary)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
	
	
	// MARK: - Public Methods
	
	public func tipAmount() -> Float {
		return self.tipViews[self.selectedIndex ?? 0].tipAmount ?? 0
	}
	
	
    // MARK: - Private Methods
	
    private func commonInit() {
        setupTipViews()
    }
    
    private func setupTipViews() {
        for (i, tipView) in tipViews.enumerated() {
            tipView.addAction(for: UIControlEvents.touchUpInside) { [weak self] in
				guard let sSelf = self else { return }
				
                sSelf.tipViews.forEach() {
                    $0.isTipSelected = false
                }
				
				tipView.isTipSelected = /*self.selectedIndex != i*/ true
				sSelf.selectedIndex = (tipView.isTipSelected) ? i : nil
				
				if let callback = sSelf.tappedActionCallback {
					callback(tipView.isTipSelected ? tipView.tipAmount : 0, (i+1)==sSelf.tipViews.count)
				}
            }
            addSubview(tipView)
        }
    }
    
    private func update() {
		if let selectedIndex = selectedIndex {
			self.tipViews.forEach() {
				$0.isTipSelected = false
			}
			tipViews[selectedIndex].isTipSelected = !tipViews[selectedIndex].isTipSelected
		}

    }
    
    // MARK: - UIView Helpers
    override func layoutSubviews() {
        let tipViewWidth = self.frame.width / CGFloat(tipViews.count)
        for (i, tipView) in tipViews.enumerated() {
            tipView.frame = CGRect(CGFloat(i) * tipViewWidth, 0.0, tipViewWidth, self.frame.height)
            
            
        }
    }
    
}
