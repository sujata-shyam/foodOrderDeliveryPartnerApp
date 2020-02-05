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


//TEMP CODE. DELETE AFTER THOROUGH TESTING

//for spice curry
//SocketIOManager.sharedInstance.emitLocationUpdate(dpLatitude: "12.981264900000001", dpLongitude: "77.6461579")
//For Sway
//SocketIOManager.sharedInstance.emitLocationUpdate(dpLatitude: "13.020890300000001",dpLongitude: "77.643156")
