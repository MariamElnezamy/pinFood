//
//  LogoAnimationViewController.swift
//  Rescounts
//
//  Created by Monica Luo on 2018-11-05.
//  Copyright © 2018 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class LogoAnimationViewController: UIViewController {
	
	
	private var toVC =  UIViewController()
	
	//MARK: - Initialize
	
	convenience init() {
		self.init()
	}
	
	init(to : UIViewController) {
		super.init(nibName: nil, bundle: nil)
		toVC = to
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .gold
		
		
		NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: VideoMaker.main.player.currentItem)
		
		
		VideoMaker.main.playerLayer.frame = view.bounds
		self.view.layer.addSublayer(VideoMaker.main.playerLayer)
		VideoMaker.main.playLogo()
		
		
	}
	
	// MARK: - private funcs
	
	@objc private func playerDidFinishPlaying(note: NSNotification) {
		//The video is over, go to ToVC
		let nc = BaseNavigationController(rootViewController: toVC)
		nc.setNavigationBarHidden(true, animated: false)
		
		if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
			appDelegate.window?.rootViewController = nc
		}
	}
}
