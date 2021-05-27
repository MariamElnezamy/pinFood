//
//  StarGroup.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-23.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class StarGroup: UIView {
	
	private var stars: [StarView] = []
	private var title = UILabel()
	private let label = UILabel()
	private let icon = UIImageView()
	public var value: CGFloat = 0.0
	private var avrgRating: Float?
    private var isStarsSelectable = false
	
	private var onColour:  UIColor = UIColor.black
	private var offColour: UIColor = UIColor.lightGray
	
	private let kIconSpacer: CGFloat = 3
	
	
    init(isSelectable: Bool = false) {
        super.init(frame: .arbitrary)
        commonInit(isSelectable: isSelectable)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit(isSelectable: Bool = false) {
        isStarsSelectable = isSelectable
    }

	// MARK: - Public Methods
	
	public func setColours(on: UIColor, off: UIColor? = nil) {
		onColour = on
		if let oc = off {
			offColour = oc
		}
		updateStarColours()
	}
	
	public func setValue(_ value: Float, maxValue: Int? = nil, numReviews: Int? = nil, iconName: String? = nil, titleText: String? = nil) {
		self.value = CGFloat(value)
        //if you need number of reviews user numReviews
		self.avrgRating = value
		
		updateAvrgRating()
		
		if let max = maxValue {
			if max != stars.count {
				stars.forEach { $0.removeFromSuperview() }
				stars.removeAll(keepingCapacity: true)
				for i in 1...max {
                        let sv = StarView()
                    if (isStarsSelectable) {
                        sv.addAction(for: .touchUpInside) {
							let newValue = Int(self.value) != i ? i : 0
							self.setValue(Float(newValue), maxValue: maxValue, numReviews: numReviews, iconName: iconName)
                        }
                    }
					stars.append(sv)
					addSubview(sv)
				}
				updateStarColours()
			}
		}
		addSubview(label)
		
		for i in 0..<stars.count {
			stars[i].percent = CGFloat((0...1.0).clamp(self.value - CGFloat(i)))
			stars[i].setNeedsDisplay()
		}
		
		icon.contentMode = .scaleAspectFit
		setIconName(iconName)
		addSubview(icon)
		
		setTitleLabel(titleText)
		addSubview(title)
		
		setNeedsLayout()
	}
	
	public func setTitleLabel(_ txt: String?) {
		title.text = txt
		title.font = UIFont.lightRescounts(ofSize: 14)
		title.textAlignment = .left
	}
	
	public func setIconName(_ imageName: String?) {
		if let name = imageName {
			setIcon(UIImage(named: name))
		} else {
			setIcon(nil)
		}
	}
	
	public func setIcon(_ image: UIImage?) {
		if (image != icon.image) {
			icon.image = image
			setNeedsLayout()
		}
	}
	
	public func idealWidthForHeight(_ height: CGFloat) -> CGFloat {
		let iconWidth: CGFloat = (icon.image != nil) ? height + kIconSpacer : 0
		return CGFloat(stars.count) * height + iconWidth + ceil(label.sizeThatFits(CGSize(400,400)).width) + 4 // Final '4' adds a bit of space before label
	}
	
	
	// MARK: - UIView Methods
	
	override func layoutSubviews() {
		super.layoutSubviews()
		var x: CGFloat = 0
		if (icon.image != nil) {
			icon.frame = CGRect(0, 0, frame.size.height, frame.size.height)
			x = frame.size.height + kIconSpacer
		}
		
		if (title.text != nil) {
			title.frame = CGRect(x , 0.0, frame.size.height * 3, frame.size.height)
			x = x + frame.size.height * 3 + kIconSpacer
		}
		
		for i in 0..<stars.count {
			stars[i].frame = CGRect(x + CGFloat(i)*frame.height, 0.0, frame.height, frame.height)
		}
		let labelX = x + CGFloat(stars.count)*frame.height
		label.frame = CGRect(labelX, 0.0, frame.width - labelX, frame.height)
	}
	
	
	// MARK: - Private Helpers
	
	private func updateStarColours() {
		for star in stars {
			star.onColour = onColour
			star.offColour = offColour
		}
	}
	
	private func updateAvrgRating() {
		if let val = self.avrgRating {
			label.text = "(\(String(format:"%.1f", val)))"
			label.textColor = .gray
			label.font = UIFont.lightRescounts(ofSize: 15.0)
			label.adjustsFontSizeToFitWidth = true
			label.isHidden = false
		} else {
			label.isHidden = true
		}
	}
}
