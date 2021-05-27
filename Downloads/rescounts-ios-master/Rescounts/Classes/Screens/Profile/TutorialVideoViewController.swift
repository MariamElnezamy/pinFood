//
//  TutorialVideoViewController.swift
//  Rescounts
//
//  Created by Monica Luo on 2019-01-31.
//  Copyright © 2019 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer

class TutorialVideoViewController : BaseViewController {
	
	private var toVC = UIViewController()
    private let closeButton =  UIButton()
	
	// MARK: - Initialize
	
	convenience init() {
		self.init()
	}
	
	init(to: UIViewController) {
		super.init(nibName:nil, bundle: nil)
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
		view.backgroundColor = .darkGray
		
		let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
			(self.navigationController?.navigationBar.frame.height ?? 0.0)
		//Step 1
		VideoMaker.main.setUp(name: "tut", type: "mp4") // TODO: CHange this to tut
		
		//Step 2
		NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: VideoMaker.main.player.currentItem)
		
		//Step 3
		VideoMaker.main.playerLayer.frame = CGRect(view.frame.x, view.frame.y + topBarHeight, view.frame.width, view.frame.height - topBarHeight)
		
		self.view.layer.addSublayer(VideoMaker.main.playerLayer)
		
		//Step 4
		VideoMaker.main.playLogo()
        
        setupCloseButton()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		navigationController?.setNavigationBarHidden(false, animated: true)
		navigationController?.navigationBar.backgroundColor = .dark
		navigationController?.navigationBar.barTintColor = .dark
		navigationController?.navigationBar.tintColor = .white
		navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
		navigationController?.navigationBar.barStyle = .black
		
	}
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let buttonSize : CGFloat = 60.0
        closeButton.frame = CGRect(view.frame.width - buttonSize, VideoMaker.main.playerLayer.frame.minY, buttonSize, buttonSize)
    }
	
	override internal func orderToolbarItems() -> [UIBarButtonItem]? {
		// We don't want to show the order toolbar
		return nil
	}
	
	// MARK: - private funcs
	
	@objc private func playerDidFinishPlaying(note: NSNotification) {
        dismissView()
	}
    
    private func setupCloseButton(){
		closeButton.setTitle("SKIP", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
		closeButton.titleLabel?.font = UIFont.boldRescounts(ofSize: 17)
		closeButton.titleLabel?.layer.shadowColor = UIColor.black.cgColor
		closeButton.titleLabel?.layer.shadowRadius = 1
		closeButton.titleLabel?.layer.shadowOpacity = 1
		closeButton.titleLabel?.layer.shadowOffset = CGSize(width: 2, height: 2)
		closeButton.titleLabel?.layer.masksToBounds = false
        closeButton.addAction(for: .touchUpInside) { [weak self] in
            self?.dismissView()
        }
        if ((toVC as? ProfileViewController) != nil) {
            closeButton.isHidden = true
        } else {
            closeButton.isHidden = false
        }
        
        self.view.addSubview(closeButton)
        
    }
    
    private func dismissView() {
        
        if ((toVC as? ProfileViewController) != nil) {
            //if video is over, go back to previous view
            self.navigationController?.popViewController(animated: true)
        } else {
            //The video is over, go to ToVC
            let nc = BaseNavigationController(rootViewController: toVC)
            nc.setNavigationBarHidden(false, animated: false)
            
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.window?.rootViewController = nc
            }
        }
    }
	
}
