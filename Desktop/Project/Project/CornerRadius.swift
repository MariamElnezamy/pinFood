//
//  CornerRadius.swift
//  ٍSignUpApp
//
//  Created by Admin on 6/23/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit


extension UIView {
    
    @IBInspectable var CornerRadius : CGFloat{
        
        get{ return self.layer.cornerRadius }
        set{ self.layer.cornerRadius = newValue }

    }



}
