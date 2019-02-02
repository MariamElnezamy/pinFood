//
//  ResetPassViewController.swift
//  Project
//
//  Created by Admin on 10/25/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit
import Parse





class ResetPassViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


    
    }

    @IBOutlet var EmailText: UITextField!
  
    @IBAction func SendBtnAction(_ sender: UIButton) {
        
        
        let EmailText = self.EmailText.text
        
        if (EmailText?.isEmpty)! {
            
            let MessageBox = messageBox.show("you must write your Email" , MyVC: self)
            
            return MessageBox
        }
        
        
      
        PFUser.requestPasswordResetForEmail(inBackground: EmailText!) { (success:Bool, error:Error?) in
            
            
            if (error==nil){
                
                
                let userMessage:String = "An email message was send to ur \(EmailText)"
                
                messageBox.show(userMessage, MyVC: self)
                
                
                
            }else{
                
                
                
                let userMessage:String = error!.localizedDescription
                
                messageBox.show(userMessage, MyVC: self)

            
                
            }
        }
        
        
    }
    
    
    
    
    @IBAction func CancelBtnAction(_ sender: UIButton) {
        
        
        dismiss(animated: true, completion: nil)
        
        
    }

}
