//
//  orderDetailsViewController.swift
//  foodOrderDeliveryPartnerApp
//
//  Created by Sujata on 20/01/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import UIKit
import CoreLocation
import Contacts

class orderDetailsViewController: UIViewController
{
    var orderId : String?
    var clientLocation: Location?
    var restaurantLocation: Location?
    
    @IBOutlet weak var lblNoOrder: UILabel!
    @IBOutlet weak var viewOrderDetails: UIView!
    @IBOutlet weak var lblOrderID: UILabel!
    @IBOutlet weak var txtViewDetails: UITextView!
    @IBOutlet weak var txtViewRestaurantDetails: UITextView!
    @IBOutlet weak var txtViewClientAddress: UITextView!
    
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
//            timer?.invalidate()
//            timer = nil
//            print("TIMER INVALIDATED")
            
            self.orderId = orderID
            
            if let restaurantID = orderDetail.first?.restaurantId
            {
                DispatchQueue.global(qos: .userInteractive).async {
                    self.getRestaurantDetails(restaurantID)
                }
            }
            
            if let userLocation = orderDetail.first?.location
            {
                self.clientLocation = userLocation
                
                DispatchQueue.global(qos: .userInteractive).async {
                    self.getUserAddress(userLocation)
                }
            }
            
            let arrOrderItems = Array(orderDetail.first!.cartItems!.values) as! [CartItemDetail]
            var orderString = ""
            
            if arrOrderItems.count > 0
            {
                for item in arrOrderItems
                {
                    orderString.append("\(item.name!) - \(item.quantity!),\n")
                }
            }
           
            DispatchQueue.main.async
            {
                self.lblNoOrder.isHidden = true
                self.viewOrderDetails.isHidden = false
                self.lblOrderID.text = "ORDER #\(orderID.prefix(6))"
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let title = NSMutableAttributedString(string:"Order Details: ", attributes: [
                    .foregroundColor: UIColor(named: "Fire Brick")!,
                    .font: UIFont.boldSystemFont(ofSize: 17)
                    ])
                
                let body = NSAttributedString(string:orderString, attributes: [
                    .foregroundColor: UIColor.black,
                    .font: UIFont.systemFont(ofSize: 15),
                    .paragraphStyle: paragraphStyle
                    ])
                
                title.append(body)
                
                self.txtViewDetails.attributedText = title
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
    
    func getRestaurantDetails(_ restaurantId: String)
    {
        let urlString = "https://tummypolice.iyangi.com/api/v1/restaurant/info?id=\(restaurantId)"
        
        let url = URL(string: urlString)
        
        if let url = url{
            let task = URLSession.shared.dataTask(with: url){ (data, response, error) in
                guard let data =  data else { print("URLSession not workig")
                    return }
                do
                {
                    let restDetail = try JSONDecoder().decode(Restaurant.self, from: data)
                    
                    if restDetail.latitude != nil, restDetail.longitude != nil
                    {
                        self.restaurantLocation = Location(latitude: restDetail.latitude, longitude: restDetail.longitude)
                    }
                    
                    DispatchQueue.main.async
                    {
                        let title = NSMutableAttributedString(string:"Restaurant Address: ", attributes: [
                            .foregroundColor: UIColor(named: "Fire Brick")!,
                            .font: UIFont.boldSystemFont(ofSize: 17)
                            ])
                        
                        let body = NSAttributedString(string:restDetail.city!, attributes: [
                            .foregroundColor: UIColor.black,
                            .font: UIFont.systemFont(ofSize: 15)
                            ])
                        
                        title.append(body)
                        
                        self.txtViewRestaurantDetails.attributedText = title
                    }
                }
                catch
                {
                    print("error:\(error)")
                }
            }
            task.resume()
        }
    }
    
    //Below function for reverse geo-coding
    func getUserAddress(_ userAddress: Location)
    {
        //DO NOT DELETE. ORIGINAL CODE
        let location = CLLocation(latitude: Double((userAddress.latitude)!)!, longitude: Double((userAddress.longitude)!)!)
        
        //let location = CLLocation(latitude:13.025232483644993, longitude:77.65087198473294) //For SPT //FOR SIMULATOR
        
        //let location = CLLocation(latitude:12.9615402 , longitude: 77.6441973) //For geekSkool//FOR SIMULATOR
        
        
        
        CLGeocoder().reverseGeocodeLocation(location, preferredLocale: .autoupdatingCurrent) { (clPlacemark: [CLPlacemark]?, error: Error?) in
            guard let place = clPlacemark?.first else {
                print("No placemark from Apple: \(String(describing: error))")
                return
            }
            
            let postalAddressFormatter = CNPostalAddressFormatter()
            postalAddressFormatter.style = .mailingAddress
            var addressString: String?
            if let postalAddress = place.postalAddress {
                addressString = postalAddressFormatter.string(from: postalAddress)
                
                let title = NSMutableAttributedString(string:"Client Address: ", attributes: [
                    .foregroundColor: UIColor(named: "Fire Brick")!,
                    .font: UIFont.boldSystemFont(ofSize: 17)
                    ])
                let body = NSAttributedString(string:addressString!, attributes: [
                    .foregroundColor: UIColor.black,
                    .font: UIFont.systemFont(ofSize: 15)
                    ])
                title.append(body)

                self.txtViewClientAddress.attributedText = title
            }
        }
}
    
    @IBAction func btnAcceptOrderTapped(_ sender: UIButton)
    {
        if(orderId != nil)
        {
            SocketIOManager.sharedInstance.emitTaskAcception(self.orderId!)
            /////
            timer?.invalidate()
            timer = nil
            print("TIMER INVALIDATED")
            /////
            
            performSegue(withIdentifier: "goToMaps", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let mapVC = segue.destination as? mapViewController
        {
            mapVC.orderId = self.orderId
            mapVC.clientLocation = self.clientLocation
            mapVC.restaurantLocation = self.restaurantLocation
        }
    }
    

    

    
}
