//
//  API.swift
//  Project
//
//  Created by Admin on 11/6/18.
//  Copyright © 2018 mariamelnezamy. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class API: NSObject {
    

    class func logIn(Email:String, Password:String, Completion:@escaping(_ error:Error?, _ success:Bool?)->Void ){
        
        
        let url = "http://orabi.rmal.com.sa/derby/api/auth/signin"
        
        let parameters = [
            
            "email":Email,
            "password":Password
            
        ]

    
        print("parameters\(parameters)")
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding:
            URLEncoding.default , headers: nil)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                
                switch response.result{
                case .failure(let error):
                    Completion(error,false)
                    print(error)
                case .success(let value):
                    let json = JSON(value)
                    print(json)
                    
                    if let api_token = json["user"]["api_token"].string{
                        
                        print("api_token: \(api_token)")
                        Completion(nil,true)
                        
                    }
                }
                
        }
        
    
    
    }
    

}
