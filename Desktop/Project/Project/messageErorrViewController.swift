//
//  messageErorrViewController.swift
//  Project
//
//  Created by Admin on 10/28/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit

class messageErorrViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageText.text = message
  
    }
    
    
    var message:String!
    
    @IBOutlet var ViewMessage: UIView!{
    
        didSet{
        
            ViewMessage.layer.cornerRadius = 10
            ViewMessage.layer.borderColor = UIColor.orange.cgColor
            ViewMessage.layer.borderWidth = 1.5
        
        
        }
    
    }
    
    
    @IBAction func OkBtn(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
        
    }
    
    
    @IBOutlet var messageText: UILabel!
    
    
}




class messageBox {
    
    
    static func show(_ message: String , MyVC :UIViewController){
        
        let StoryBoard = UIStoryboard.init(name: "messageErorrViewController", bundle: nil)
        let VC = StoryBoard.instantiateViewController(withIdentifier: "messageErorrViewController") as! messageErorrViewController
        
        
        VC.modalPresentationStyle = .overFullScreen
        VC.modalTransitionStyle = .crossDissolve
        
        
        
        VC.message = message
        MyVC.present(VC, animated: true, completion: nil)
        
    }
    
    
    
    
}

