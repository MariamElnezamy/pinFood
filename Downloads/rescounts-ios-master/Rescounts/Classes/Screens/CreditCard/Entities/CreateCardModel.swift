//
//  CreateCardModel.swift
//  Rescounts
//
//  Created by Admin on 20/05/2021.
//  Copyright © 2021 ZeMind Game Studio Ltd. All rights reserved.
//

import Foundation

// MARK: - CreateCardTokenModel
struct CreateCardTokenModel: Codable {
    let id, object: String?
    let card: CardData?
    let clientIP: String?
    let created: Int?
    let livemode: Bool?
    let type: String?
    let used: Bool?
    let error: CardError?
    enum CodingKeys: String, CodingKey {
        case id, object, card
        case clientIP = "client_ip"
        case created, livemode, type, used
        case error
    }
}

// MARK: - Card
struct CardData: Codable {
    let id, object, addressCity, addressCountry: String?
    let addressLine1, addressLine1Check, addressLine2, addressState: String?
    let addressZip, addressZipCheck, brand, country: String?
    let currency, cvcCheck: String?
    let dynamicLast4: Int?
    let expMonth, expYear: Int?
    let fingerprint, funding, last4: String?
    let metadata: Metadata?
    let name: String?
    let tokenizationMethod: String?

    enum CodingKeys: String, CodingKey {
        case id, object
        case addressCity = "address_city"
        case addressCountry = "address_country"
        case addressLine1 = "address_line1"
        case addressLine1Check = "address_line1_check"
        case addressLine2 = "address_line2"
        case addressState = "address_state"
        case addressZip = "address_zip"
        case addressZipCheck = "address_zip_check"
        case brand, country, currency
        case cvcCheck = "cvc_check"
        case dynamicLast4 = "dynamic_last4"
        case expMonth = "exp_month"
        case expYear = "exp_year"
        case fingerprint, funding, last4, metadata, name
        case tokenizationMethod = "tokenization_method"
    }
}

// MARK: - Metadata
struct Metadata: Codable {
}


// MARK: - Error
struct CardError: Codable {
    let code: String?
    let docURL: String?
    let message, param, type: String?

    enum CodingKeys: String, CodingKey {
        case code
        case docURL = "doc_url"
        case message, param, type
    }
}
