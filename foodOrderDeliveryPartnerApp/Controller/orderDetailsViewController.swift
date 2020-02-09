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
    var orderId : String?
    var clientLocation: Location?
    
    @IBOutlet weak var lblNoOrder: UILabel!
    @IBOutlet weak var viewOrderDetails: UIView!
    @IBOutlet weak var lblOrderID: UILabel!
    @IBOutlet weak var txtViewDetails: UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleIncomingOrder), name: NSNotification.Name("gotOrderDetail"), object: nil)
    }
    
    @objc func handleIncomingOrder(notification: Notification)
    {
        let orderDetail = notification.object as! [OrderDetail]        
        
        if let orderID = orderDetail.first?.orderId
        {
            print("Notification orderID: \(orderID)")
            
            self.orderId = orderID
            self.clientLocation = orderDetail.first?.location
            
            let orderItem = Array(orderDetail.first!.cartItems!.values) as! [CartItemDetail]
           
            DispatchQueue.main.async
            {
                self.lblNoOrder.isHidden = true
                self.viewOrderDetails.isHidden = false
                self.lblOrderID.text = "ORDER #\(orderID.prefix(6))"
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
    
    @IBAction func btnAcceptOrderTapped(_ sender: UIButton)
    {
        if(orderId != nil)
        {
            SocketIOManager.sharedInstance.emitTaskAcception(self.orderId!)
            
            performSegue(withIdentifier: "goToMaps", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let mapVC = segue.destination as? mapViewController
        {
            mapVC.orderId = self.orderId
            mapVC.clientLocation = self.clientLocation
        }
    }
    

    

    
}
