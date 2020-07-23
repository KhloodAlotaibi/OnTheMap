//
//  StudentName.swift
//  OnTheMap
//
//  Created by Khlood on 7/15/20.
//  Copyright © 2020 Khlood. All rights reserved.
//

import Foundation

struct StudentName: Codable {
    
    let firstname: String?
    let lastname: String?
    let nickname: String?
    
    enum CodingKeys: String, CodingKey {
        case firstname = "first_name"
        case lastname = "last_name"
        case nickname
    } 
}
