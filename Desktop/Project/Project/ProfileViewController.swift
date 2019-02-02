//
//  ProfileViewController.swift
//  Project
//
//  Created by Admin on 10/31/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit


class ProfileViewController: UIViewController ,UIImagePickerControllerDelegate ,UINavigationControllerDelegate{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        ImagePicker.delegate = self
//        ImagePicker.sourceType = .photoLibrary
//        ImagePicker.allowsEditing = true
//        
//        presentViewController(ImagePicker, animated: true, completion: nil)
//
        
        
    }
    
    @IBOutlet var imageView: UIImageView!

    let ImagePicker = UIImagePickerController()
    
    
    @IBAction func loadImageButtonTapped(sender: UIButton) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    

    
  
    
    
    @IBAction func loadImageButtonTapped(sender: UIButton) {
        
        ImagePicker.allowsEditing = false
        ImagePicker.sourceType = .photoLibrary
        
        
        
    }
    
    
    
    
    

}
