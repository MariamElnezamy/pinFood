//
//  CreditCard+Network.swift
//  Rescounts
//
//  Created by Admin on 20/05/2021.
//  Copyright © 2021 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation

extension CreditCardVC {
    
    func creditCard(param:[String: String]){
        
        let url = "https://api.stripe.com/v1/tokens"
        
        Services.shared.PostData(url: url, parameters: param, headers: userHeader) { (data: CreateCardTokenModel?, error: Error?) in
            if let error = error {
                self.Alert("Error", error.localizedDescription)
                print(error.localizedDescription)
            }else{
                if data?.error == nil {
                    self.dismiss(animated: false, completion: nil)
                    self.onVCDismiss?()
                }else{
                    self.Alert("", data?.error?.message ?? "")
                }
            }
        }
    }
    
}
