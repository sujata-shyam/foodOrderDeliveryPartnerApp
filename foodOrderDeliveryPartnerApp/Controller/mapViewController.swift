//
//  mapViewController.swift
//  foodOrderDeliveryPartnerApp
//
//  Created by Sujata on 06/02/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import UIKit
import MapKit

class mapViewController: UIViewController
{
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnOrderPicked: UIButton!
    @IBOutlet weak var btnOrderDelivered: UIButton!
    
    var orderId : String? //Value passed from prev.View Controller thru. segue
    var clientLocation: Location? //Value passed from prev.View Controller thru. segue
    var restaurantLocation: Location? //Value passed from prev.View Controller thru. segue
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        getDirections(restaurantLocation!, "Restaurant")
    }
        
    func getDirections(_ destination: Location, _ title: String)
    {
        let sourceMapItem = MKMapItem.forCurrentLocation()
        
        let destCoordinate = CLLocationCoordinate2D(latitude: Double((destination.latitude)!)!, longitude: Double((destination.longitude)!)!)
        
        let destPlacemark = MKPlacemark(coordinate: destCoordinate)

        let destMapItem = MKMapItem(placemark: destPlacemark)
        destMapItem.name = title
        
        MKMapItem.openMaps(with: [sourceMapItem, destMapItem], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
    
    @IBAction func btnOrderPickedTapped(_ sender: UIButton)
    {
        SocketIOManager.sharedInstance.emitOrderPicked(orderId!)
        btnOrderDelivered.isEnabled = true
        btnOrderDelivered.setTitleColor(#colorLiteral(red: 0.737254902, green: 0.1921568627, blue: 0.08235294118, alpha: 1), for: .normal)
        
        btnOrderPicked.isEnabled = false
        btnOrderPicked.setTitleColor(#colorLiteral(red: 0.6941176471, green: 0.537254902, blue: 0.5568627451, alpha: 1), for: .normal)

        getDirections(clientLocation!, "Client")
    }
    
    @IBAction func btnOrderDeliveredTapped(_ sender: UIButton)
    {
        SocketIOManager.sharedInstance.emitOrderDelivered(orderId!)
        performSegue(withIdentifier: "goToCompletion", sender: self)
        LocationManager.shared.stop()
    }
}

