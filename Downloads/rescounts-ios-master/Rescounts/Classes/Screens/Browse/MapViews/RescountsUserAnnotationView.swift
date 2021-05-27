//
//  RescountsUserAnnotationView.swift
//  Rescounts
//
//  Created by Patrick Weekes on 2018-07-20.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import MapKit

class RescountsUserAnnotationView: MKAnnotationView {
	private let solidView   = UIView()
	private let pulsingView = UIView()
	
	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		self.frame = CGRect(0, 0, 40, 40)
		
		solidView.backgroundColor = .gold
		solidView.layer.masksToBounds = true
		addSubview(solidView)
		
		pulsingView.frame = self.bounds
		pulsingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		pulsingView.backgroundColor = .gold
		pulsingView.layer.masksToBounds = true
		pulsingView.alpha = 0.7
		addSubview(pulsingView)
		
		UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations: { [weak self] in
			self?.pulsingView.alpha = 0.3
		}, completion: nil)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		solidView.frame = bounds.insetBy(bounds.width / 4)
		
		solidView.layer.cornerRadius   = frame.width / 4
		pulsingView.layer.cornerRadius = frame.width / 2
	}
}
