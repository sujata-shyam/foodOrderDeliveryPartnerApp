//
//  User.swift
//  foodOrderDeliveryPartnerApp
//
//  Created by Sujata on 15/01/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import Foundation

struct LoginRequest:Codable
{
    let id : String?
}

struct LoginResponse:Codable
{
    let msg: String?
    let session: String?
    let id: String?
    let phone: String?
}
