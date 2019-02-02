//
//  menuSideViewController.swift
//  Project
//
//  Created by Admin on 10/28/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit
import Firebase


class menuSideViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        signinController.Email.text = Email.text
        Email.text = mail

    }
    
    
    var mail:String=""

    @IBOutlet var Email: UILabel!
    
    var signinController = SigninViewController()
    
    

    @IBAction func SignOut(_ sender: UIButton) {
        
      
        try? Auth.auth().signOut()
        
        dismiss(animated: true, completion: nil)
        
        
        
        
        
        
    }
    
    
    

}
