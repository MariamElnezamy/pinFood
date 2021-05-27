//
//  CircularLoadingSpinner.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-08-05.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import UIKit

class CircularLoadingSpinner: UIView {
	
	public var lineWidth: CGFloat = 3
	public var colour: UIColor = .primary
	
	private var startPct: CGFloat = 0
	private var endPct: CGFloat = 0.9
	private var age: TimeInterval = 0
	private let kEndOffset: TimeInterval = 10
	private let kSpeed: TimeInterval = 4
	private var timer: CADisplayLink?
	
	
	// MARK: - Initialization
	
	convenience init() {
		self.init(frame: .arbitrary)
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
		self.backgroundColor = .clear
		start()
	}
	
	
	// MARK: - UIView Methods
	
    override func draw(_ rect: CGRect) {
		if let context = UIGraphicsGetCurrentContext() {
			let r = (rect.width - lineWidth) * 0.5
			
			colour.setStroke()
			context.setLineWidth(lineWidth)
			context.addArc(center: rect.midPt, radius: r, startAngle: startPct*2*CGFloat.pi, endAngle: endPct*2*CGFloat.pi, clockwise: false)
			context.strokePath()
		}
    }
	
	
	// MARK: - Public Methods
	
	public func start() {
		stop()
		timer = CADisplayLink(target: self, selector: #selector(update(_:)))
		timer?.add(to: .main, forMode: .defaultRunLoopMode)
	}
	
	public func stop() {
		timer?.invalidate()
		timer = nil
	}
	
	
	// MARK: - Private Methods
	
	@objc private func update(_ sender: CADisplayLink) {
		age += sender.duration
		startPct = (startPct + CGFloat(sender.duration * (1+sin(kSpeed*age)))).remainder(dividingBy: 1)
		endPct = (endPct + CGFloat(sender.duration * (1+sin(kSpeed*(age+kEndOffset))))).remainder(dividingBy: 1)
		setNeedsDisplay()
	}
}
