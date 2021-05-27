//
//  StarView.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-06-23.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class StarView: UIControl {
	public var percent: CGFloat = 0.0
	public var onColour = UIColor.black
	public var offColour = UIColor.lightGray
	
	
	//MARK: - Initialization
	
	convenience init() {
		self.init(frame: CGRect(0.0, 0.0, 30.0, 30.0))
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
		self.backgroundColor = UIColor.clear
	}
	
	
	//MARK: - Private Methods
	
    override func draw(_ rect: CGRect) {
        // Assumes a square view
		if let context = UIGraphicsGetCurrentContext() {
			let r = rect.width * 0.5
			
			// TODO: If this is inefficient, do an if-check for solid-coloured stars and only draw once
			
			context.clip(to: CGRect(0.0, 0.0, percent*rect.width, rect.height))
			context.setFillColor(onColour.cgColor)
			context.beginPath()
			context.move   (to: CGPoint(x:rect.midX, y:0.0))
			context.addLine(to: CGPoint(x:rect.midX + r*cos((6.0*0.2+0.5)*CGFloat.pi), y: rect.midY - r*sin((6.0*0.2+0.5)*CGFloat.pi)))
			context.addLine(to: CGPoint(x:rect.midX + r*cos((2.0*0.2+0.5)*CGFloat.pi), y: rect.midY - r*sin((2.0*0.2+0.5)*CGFloat.pi)))
			context.addLine(to: CGPoint(x:rect.midX + r*cos((8.0*0.2+0.5)*CGFloat.pi), y: rect.midY - r*sin((8.0*0.2+0.5)*CGFloat.pi)))
			context.addLine(to: CGPoint(x:rect.midX + r*cos((4.0*0.2+0.5)*CGFloat.pi), y: rect.midY - r*sin((4.0*0.2+0.5)*CGFloat.pi)))
			context.closePath()
			context.fillPath()
			
			context.resetClip()
			context.clip(to: CGRect(percent*rect.width, 0.0, (1.0-percent)*rect.width, rect.height))
			context.setFillColor(offColour.cgColor)
			context.beginPath()
			context.move   (to: CGPoint(x:rect.midX, y:0.0))
			context.addLine(to: CGPoint(x:rect.midX + r*cos((6.0*0.2+0.5)*CGFloat.pi), y: rect.midY - r*sin((6.0*0.2+0.5)*CGFloat.pi)))
			context.addLine(to: CGPoint(x:rect.midX + r*cos((2.0*0.2+0.5)*CGFloat.pi), y: rect.midY - r*sin((2.0*0.2+0.5)*CGFloat.pi)))
			context.addLine(to: CGPoint(x:rect.midX + r*cos((8.0*0.2+0.5)*CGFloat.pi), y: rect.midY - r*sin((8.0*0.2+0.5)*CGFloat.pi)))
			context.addLine(to: CGPoint(x:rect.midX + r*cos((4.0*0.2+0.5)*CGFloat.pi), y: rect.midY - r*sin((4.0*0.2+0.5)*CGFloat.pi)))
			context.closePath()
			context.fillPath()
		}
    }
}
