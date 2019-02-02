//
//  SignOutViewController.swift
//  Project
//
//  Created by Admin on 10/28/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase



class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        ref = Database.database().reference()

    }

    
    
    @IBAction func Signin(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBOutlet var Email: UITextField!
    @IBOutlet var Pass: UITextField!
    
    @IBOutlet var confirmPass: UITextField!
    
    
    var ref: DatabaseReference!

    
    @IBAction func SignIn(_ sender: UIButton) {
        
        
        self.ref.child("Email").childByAutoId().setValue(Email)
        self.ref.child("Password").childByAutoId().setValue(Pass)

        //        if confirmPass != Pass {
        //
        //            let x = messageBox.show(message: "Some thing worninig in password or confirm password" , MyVC: self)
        //
        //            return x
        //
        //
        //        }
       // performSegue(withIdentifier: "SWRevealViewController", sender: nil)
        
        //
        //            Auth.auth().createUser(withEmail: Email.text!, password: Pass.text!) { (User, Error) in
        //
        
        //  if Error != nil {
        
        
        //               }else{
        //
        //                    messageBox.show(message: Error! .localizedDescription , MyVC: self)
        //
        //                    
        //                    
        //                }
    }
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        
        
        
        
        
    }
    
    
}
























