//
//  CreditCard+Scan.swift
//  Rescounts
//
//  Created by Admin on 19/05/2021.
//  Copyright © 2021 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import CardScan
import Stripe


extension CreditCardVC : ScanDelegate{
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !ScanViewController.isCompatible() {
                   // Hide your "scan card" button because this device isn't compatible
                   // with CardScan
               }
    }
    
    func startScan() {
        guard let vc = ScanViewController.createViewController(withDelegate: self) else {
            print("This device is incompatible with CardScan")
            return
        }
        self.present(vc, animated: true)
    }
    
    func userDidSkip(_ scanViewController: ScanViewController) {
        self.dismiss(animated: true)
    }
    
    func userDidCancel(_ scanViewController: ScanViewController) {
        self.dismiss(animated: true)
    }
    
    func userDidScanCard(
        _ scanViewController: ScanViewController,
        creditCard: CreditCard
    ) {
        
        let number = creditCard.number
        let expiryMonth = creditCard.expiryMonth
        let expiryYear = creditCard.expiryYear
        print("creditCard :\(creditCard.description)")
        cellsArray[0].value = "\(number)"
        cellsArray[1].value = "\(expiryYear ?? "YYYY")-\(expiryMonth ?? "MM")"
        tableView.reloadData()
        
        // If you're using Stripe and you include the CardScan/Stripe pod, you
        // can get `STPCardParams` directly from CardScan `CreditCard` objects,
        // which you can use with Stripe's APIs
        // let cardParams = creditCard.cardParams()
        
        // At this point you have the credit card number and optionally the
        // expiry. You can either tokenize the number or prompt the user for
        // more information (e.g., CVV) before tokenizing.
        self.dismiss(animated: true)
    }
}
