//
//  NewRestuarantController.swift
//  PinFood
//
//  Created by Admin on 9/12/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit

class NewRestuarantController: UITableViewController ,UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    // Image Picker and Tap into it
 
    
    @IBOutlet weak var ImageView: UIImageView!
    
    
    
    @IBOutlet var nameTextField:UITextField!
    @IBOutlet var typeTextField:UITextField!
    @IBOutlet var locationTextField:UITextField!
    @IBOutlet var yesButton:UIButton!
    @IBOutlet var noButton:UIButton!
    
    
   var isVisited = true

    
    
    let ImagePicker = UIImagePickerController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        ImagePicker.delegate = self
        ImagePicker.sourceType = .photoLibrary
        ImagePicker.allowsEditing = true
        
        
        
        let TapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(NewRestuarantController.ChooseImage))
        
        ImageView.isUserInteractionEnabled = true
        ImageView.addGestureRecognizer(TapGestureRecognizer)
        
        
    }
    
    
    
    
    
    
    @objc func ChooseImage () {
        
        let Alert = UIAlertController(title: " اختر مصدر الصورة ", message: " من اى مصدر تريد ؟ ", preferredStyle: .actionSheet)
        
        let Camera = UIAlertAction(title: "Camera", style: .default) { (AlertController) in
            
            
            self.ImagePicker.sourceType = .camera
            
            
            
            self.present(self.ImagePicker, animated: true, completion: nil)
            
            
        }
        
        
        let PhotoLibrary = UIAlertAction(title: "PhotoLibrary", style: .default) { (Alert) in
            
            
            self.ImagePicker.sourceType = .photoLibrary
            
            
            
            self.present(self.ImagePicker, animated: true, completion: nil)
            
            
        }
        
        
        let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        Alert.addAction(Camera)
        Alert.addAction(PhotoLibrary)
        Alert.addAction(Cancel)
        present(Alert, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let TheImage = info[UIImagePickerControllerEditedImage] as! UIImage
        ImageView.image = TheImage
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
        
        
    }

    // Save Button

     
    @IBAction func SaveBtn(_ sender: Any) {
        if nameTextField.text == "" || typeTextField.text == "" || locationTextField.text == "" {
            let alertController = UIAlertController(title: "Oops", message: "We can't proceed because one of the fields is blank. Please note that all fields are required.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
   
     dismiss(animated: true, completion: nil)
     }
    
    
    // Change the backgroundColor property of yesButton & noButton
    
    
    @IBAction func BeenHereButton(_ sender: UIButton) {
        
        if sender == yesButton {
            
            isVisited = true
            // Change the backgroundColor property of yesButton to red
            yesButton.backgroundColor = UIColor(red: 218.0/255.0, green: 100.0/255.0, blue: 70.0/255.0, alpha: 1.0)
            
            // Change the backgroundColor property of noButton to gray
            noButton.backgroundColor = UIColor(red: 218.0/255.0, green: 223.0/255.0, blue: 225.0/255.0, alpha: 1.0)
            print("yes")
        } else if sender == noButton {
            
            isVisited = false
            yesButton.backgroundColor = UIColor(red: 218.0/255.0, green: 223.0/255.0, blue: 225.0/255.0, alpha: 1.0)
            
            noButton.backgroundColor = UIColor(red: 218.0/255.0, green: 100.0/255.0, blue: 70.0/255.0, alpha: 1.0)
        }
        print("no")
        
    }
    

  
    
 
}


