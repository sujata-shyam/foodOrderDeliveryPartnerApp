//
//  orderDetailsViewController.swift
//  foodOrderDeliveryPartnerApp
//
//  Created by Sujata on 20/01/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import UIKit
//import SocketIO
//import CoreLocation

class orderDetailsViewController: UIViewController
{
    //let manager = SocketManager(socketURL: URL(string: "https://tummypolice.iyangi.com")!, config: [.log(true), .compress])
    //var socket:SocketIOClient!
    var orderId : String?
    
    @IBOutlet weak var lblNoOrder: UILabel!
    
    @IBOutlet weak var viewOrderDetails: UIView!
    @IBOutlet weak var lblOrderID: UILabel!
    @IBOutlet weak var txtViewDetails: UITextView!
    
    //@IBOutlet weak var btnAcceptOrder: UIButton!
    //@IBOutlet weak var btnOrderPicked: UIButton!
    //@IBOutlet weak var btnOrderDelivered: UIButton!
    //@IBOutlet weak var StackViewButtons: UIStackView!
    //@IBOutlet weak var lblSuccess: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleIncomingOrder), name: NSNotification.Name("gotOrderDetail"), object: nil)
        
        //self.socket = self.manager.defaultSocket
//        print(locationManager.location?.coordinate.latitude as Any)
//        print(locationManager.location?.coordinate.longitude as Any)
        //setSocketEvents()
    }
    
    @objc func handleIncomingOrder(notification: Notification)
    {
        let orderDetail = notification.object as! [OrderDetail]
        
        //print("Notification orderDetail: \(orderDetail)")
        
        if let orderID = orderDetail.first?.orderId
        {
            print("Notification orderID: \(orderID)")
            
            self.orderId = orderID
            let orderItem = Array(orderDetail.first!.cartItems!.values) as! [CartItemDetail]
           
            DispatchQueue.main.async
            {
                    self.lblNoOrder.isHidden = true
                    self.viewOrderDetails.isHidden = false
                    self.lblOrderID.text = orderID
            }
        }
        else
        {
            DispatchQueue.main.async
                {
                    self.lblNoOrder.isHidden = false
                    self.viewOrderDetails.isHidden = true
            }
        }
    }
    
    //MARK:- Socket functions
    
//    private func setSocketEvents()
//    {
//        if let orderID = SocketIOManager.sharedInstance.onNewTask()
//        {
//            self.orderId = orderID
//            
//            DispatchQueue.main.async
//            {
//                self.lblNoOrder.isHidden = true
//                self.StackViewButtons.isHidden = false
//                
//                self.btnOrderPicked.isEnabled = false
//                self.btnOrderDelivered.isEnabled = false
//            }
//        }
//        else
//        {
//            DispatchQueue.main.async
//            {
//                self.lblNoOrder.isHidden = false
//                self.StackViewButtons.isHidden = true
//            }
//        }
//    }
    
//    private func setSocketEvents()
//    {
//        self.socket.on(clientEvent: .connect) { (data, ack) in
//            print(data)
//            print("Socket connected")
//
//            self.socket.emit("active delivery partner", (defaults.string(forKey: "userId")!))
//
//
////            let dpLocation = [
////                "location" : [
////                    "latitude": locationManager.location?.coordinate.latitude,
////                    "longitude": locationManager.location?.coordinate.longitude,
////                ]
////            ]
////
////            self.socket.emit("update location", dpLocation)
//
//        }
//
//        self.socket.on(clientEvent: .ping) { (_, _) in
//            print("PING")
//
//            let dpLocation = [
//                "location" : [
////                    "latitude": String((locationManager.location?.coordinate.latitude)!),
////                    "longitude": String((locationManager.location?.coordinate.longitude)!)
////                    "latitude": "13.020890300000001",
////                    "longitude": "77.643156"
//                    "latitude": "12.981264900000001",
//                    "longitude": "77.6461579"
//
//                ]
//            ]
//            self.socket.emit("update location", dpLocation)
//        }
//
//
//
//        self.socket.on("new task") { data, ack in
//            print(data)
//
//            do
//            {
//                let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
//
//                let orderDetail = try JSONDecoder().decode([OrderDetail].self, from: jsonData)
//
//                print(orderDetail)
//
//                if let orderID = orderDetail.first?.orderId
//                {
//                    print(orderID)
//                    self.orderId = orderID
//
//                    DispatchQueue.main.async
//                    {
//                        self.lblNoOrder.isHidden = true
//                        self.btnAcceptOrder.isHidden = false
//                    }
//                }
//                else
//                {
//                    DispatchQueue.main.async
//                    {
//                        self.lblNoOrder.isHidden = false
//                        self.btnAcceptOrder.isHidden = true
//                    }
//                }
//            }
//            catch
//            {
//                print(error)
//            }
//        }
//
//        self.socket.connect()
//    }
//
//    private func closeSocketConnection() {
//        self.socket.disconnect()
//    }
    
    @IBAction func btnAcceptOrderTapped(_ sender: UIButton)
    {
        if(orderId != nil)
        {
            //self.socket.emit("task accepted", self.orderId!)
            SocketIOManager.sharedInstance.emitTaskAcception(self.orderId!)
            //uncomment later
            /*
            self.btnAcceptOrder.isEnabled = false
            self.btnOrderPicked.isEnabled = true
            self.btnOrderDelivered.isEnabled = false
            */
        }
    }
    
    @IBAction func btnOrderPickedUpTapped(_ sender: UIButton)
    {
        SocketIOManager.sharedInstance.emitOrderPicked()
        
        //uncomment later
        /*
        self.btnAcceptOrder.isEnabled = false
        self.btnOrderPicked.isEnabled = false
        self.btnOrderDelivered.isEnabled = true
        */
    }
    
    @IBAction func btnOrderDeliveredTapped(_ sender: UIButton)
    {
        SocketIOManager.sharedInstance.emitOrderDelivered()
        //self.StackViewButtons.isHidden = true
        //self.lblSuccess.isHidden = false
        
        //locationManager.stopUpdatingLocation()
        LocationManager.shared.stop()
    }
    
    @IBAction func btnLogoutTapped(_ sender: UIButton)
    {
        clearUserDefaults()
        performSegue(withIdentifier: "unwindToLogin", sender: self)
    }
    
    func clearUserDefaults()
    {
        //Below: Commented on 4th Feb
        /*
        defaults.set(false, forKey: "isUserLoggedIn")
        defaults.set(nil, forKey: "userMessage")
        defaults.set(nil, forKey: "userSession")
        defaults.set(nil, forKey: "userId")
        defaults.set(nil, forKey: "userPhone")
        */
        //Above: Commented on 4th Feb
        
        //Below: Added on 4th Feb
        if let bundleID = Bundle.main.bundleIdentifier
        {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        //Above: Added on 4th Feb
    }
}
