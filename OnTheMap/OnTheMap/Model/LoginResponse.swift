//
//  LoginResponse.swift
//  OnTheMap
//
//  Created by Khlood on 7/14/20.
//  Copyright © 2020 Khlood. All rights reserved.
//

import Foundation

struct LoginResponse: Codable {
    let account: Account?
    let session: Session?
}

struct Account: Codable {
    let registered: Bool?
    let key: String?
}

struct Session: Codable {
    let id: String?
    let expiration: String?
} 
