//
//  Service.swift
//  Rescounts
//
//  Created by Admin on 20/05/2021.
//  Copyright © 2021 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation
import Alamofire


let userHeader: HTTPHeaders = ["Content-Type": "application/x-www-form-urlencoded",
                               "Authorization":"Bearer sk_test_JlbCanrXxWlI0VfyLJhJGgwO"]


class Services{
    static let shared = Services()

    func PostData<T: Decodable>(url: String,parameters:[String:Any]?,headers:[String:String]?,completion: @escaping(T?, Error?)->()) {
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            switch response.result {
            case .success:
                do {
                    print(response)
                    guard let data = response.data else { return }
                    let dataModel = try JSONDecoder().decode(T.self, from: data)
                    completion(dataModel, nil)
                } catch let jsonError {
                    print(jsonError as NSError)
                    completion(nil, jsonError)
                    
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}

