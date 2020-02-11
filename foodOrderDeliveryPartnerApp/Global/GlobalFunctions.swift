//
//  GlobalFunctions.swift
//  foodOrderDeliveryPartnerApp
//
//  Created by Sujata on 15/01/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import UIKit

let defaults = UserDefaults.standard
var timer:Timer?

func displayAlert(vc: UIViewController, title: String, message: String)
{
    let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler:nil ))
    vc.present(alert, animated: true)
}

func displayAlertForSettings()
{
    let alertController = UIAlertController (title: "The app needs access to your location to function.", message: "Go to Settings?", preferredStyle: .alert)
    
    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
    }
    alertController.addAction(settingsAction)
    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
    alertController.addAction(cancelAction)
    
    if let vc = UIApplication.shared.keyWindow?.rootViewController
    {
        vc.present(alertController, animated: true, completion: nil)
    }
}
