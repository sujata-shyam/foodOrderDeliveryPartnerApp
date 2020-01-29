//
//  AppDelegate.swift
//  foodOrderDeliveryPartnerApp
//
//  Created by Sujata on 14/01/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
        SocketIOManager.sharedInstance.establishConnection()
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        SocketIOManager.sharedInstance.closeConnection()
    }
}

