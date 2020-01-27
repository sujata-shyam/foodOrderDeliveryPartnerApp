//
//  orderDetailsViewController.swift
//  foodOrderDeliveryPartnerApp
//
//  Created by Sujata on 20/01/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import UIKit
import SocketIO
import CoreLocation

class orderDetailsViewController: UIViewController
{
    let manager = SocketManager(socketURL: URL(string: "https://tummypolice.iyangi.com")!, config: [.log(true), .compress])
    var socket:SocketIOClient!
    //let locationManager = CLLocationManager()
    var orderId : String?
    
    @IBOutlet weak var lblNoOrder: UILabel!
    @IBOutlet weak var btnAcceptOrder: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.socket = self.manager.defaultSocket
   
        print(locationManager.location?.coordinate.latitude as Any)
        print(locationManager.location?.coordinate.longitude as Any)

        setSocketEvents()
    }
    
    //MARK:- Socket functions
    
    private func setSocketEvents()
    {
        self.socket.on(clientEvent: .connect) { (data, ack) in
            print(data)
            print("Socket connected")
            
            self.socket.emit("active delivery partner", (defaults.string(forKey: "userId")!))
        
            
//            let dpLocation = [
//                "location" : [
//                    "latitude": locationManager.location?.coordinate.latitude,
//                    "longitude": locationManager.location?.coordinate.longitude,
//                ]
//            ]
//
//            self.socket.emit("update location", dpLocation)
            
        }
        
        self.socket.on(clientEvent: .ping) { (_, _) in
            print("PING")
            
            let dpLocation = [
                "location" : [
                    "latitude": String((locationManager.location?.coordinate.latitude)!),
                    "longitude": String((locationManager.location?.coordinate.longitude)!)
                ]
            ]
            self.socket.emit("update location", dpLocation)
        }
        //below 2 not working
        self.socket.on("order details") {data, ack in
            
            print(data)
        }
        self.socket.on("new task") { data, ack in
            print(data)
            
            do
            {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                
                let orderDetail = try JSONDecoder().decode([OrderDetail].self, from: jsonData)
                
                print(orderDetail)
                
                if let orderID = orderDetail.first?.orderId
                {
                    print(orderID)
                    self.orderId = orderID
                    
                    DispatchQueue.main.async
                    {
                        self.lblNoOrder.isHidden = true
                        self.btnAcceptOrder.isHidden = false
                    }
                }
                else
                {
                    DispatchQueue.main.async
                    {
                        self.lblNoOrder.isHidden = false
                        self.btnAcceptOrder.isHidden = true
                    }
                }
            }
            catch
            {
                print(error)
            }
        }
        
        self.socket.connect()
    }
    
    private func closeSocketConnection() {
        self.socket.disconnect()
    }
    
    @IBAction func btnAcceptOrderTapped(_ sender: UIButton)
    {
        if(orderId != nil)
        {
            self.socket.emit("task accepted", self.orderId!)
        }
    }
    
    @IBAction func btnLogoutTapped(_ sender: UIButton)
    {
        clearUserDefaults()
        performSegue(withIdentifier: "unwindToLogin", sender: self)
    }
    
    func clearUserDefaults()
    {
        defaults.set(false, forKey: "isUserLoggedIn")
        defaults.set(nil, forKey: "userMessage")
        defaults.set(nil, forKey: "userSession")
        defaults.set(nil, forKey: "userId")
        defaults.set(nil, forKey: "userPhone")
    }
}
