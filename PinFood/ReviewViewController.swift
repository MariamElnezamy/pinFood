//
//  ReviewViewController.swift
//  PinFood
//
//  Created by Admin on 9/5/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit

class ReviewViewController: UIViewController {
    
    var restaurant:Restaurant!


    override func viewDidLoad() {
        super.viewDidLoad()

        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        backgroundImageView.addSubview(blurEffectView)
        containerView.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        
    }

    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.transform = CGAffineTransform.identity
        })
    }

   
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var containerView: UIView!
    
}
