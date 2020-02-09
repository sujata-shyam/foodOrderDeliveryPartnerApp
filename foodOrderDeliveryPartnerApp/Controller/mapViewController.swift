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
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnOrderPicked: UIButton!
    @IBOutlet weak var btnOrderDelivered: UIButton!
    
    var orderId : String? //Value passed from prev.View Controller thru. segue
    var clientLocation: Location? //Value passed from prev.View Controller thru. segue
    
    //let restaurantLocation = CLLocation(latitude:12.981264900000001, longitude:77.6461579) //For spice curry
    let restaurantLocation = CLLocation(latitude:13.020890300000001, longitude:77.643156) //For sway
    
    let reuseId = "deliveryReuseId"
    let regionRadius: CLLocationDistance = 500
    var steps = [MKRoute.Step]()
    var currentCoordinate: CLLocationCoordinate2D!
    
    
    var deliveryAnnotation: MKPointAnnotation = {
        let annotation = MKPointAnnotation()
        annotation.title = "Delivery Person"
        return annotation
    }()
    
//    var userAnnotation: MKPointAnnotation  {
//        let annotation = MKPointAnnotation()
//        annotation.title = "User"
//        annotation.coordinate = clientLocation.coordinate
//        //annotation.coordinate = CLLocationCoordinate2DMake(29.956694, 31.276854)
//        return annotation
//    }
    
    //var startingPointAnnotation: MKPointAnnotation {
    var restaurantPointAnnotation: MKPointAnnotation {

        let annotation = MKPointAnnotation()
        annotation.title = "Restaurant"
        //annotation.title = defaults.string(forKey: "restaurantName")!
        annotation.coordinate = restaurantLocation.coordinate
        return annotation
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mapView?.showsUserLocation = true
        mapView.delegate = self
        mapView.userTrackingMode = .followWithHeading
        currentCoordinate = LocationManager.shared.currentLocation.coordinate
        centerMapOnLocation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnteredRegion), name: NSNotification.Name("enteredRegion"), object: nil)
    }
    
    func centerMapOnLocation()
    {
        mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: reuseId)
        
        //mapView.addAnnotation(userAnnotation)
        mapView.addAnnotation(restaurantPointAnnotation)
        //mapView.addAnnotation(deliveryAnnotation)
        
        getDirections()
    }
    
    func getDirections()
    {
        //Substitute the below lines
        //let sourceMapItem = MKMapItem.forCurrentLocation()//gives users current location too/
        let sourcePlacemark = MKPlacemark(coordinate: currentCoordinate)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        
        let destPlacemark = MKPlacemark(coordinate: restaurantLocation.coordinate)
        let destMapItem = MKMapItem(placemark: destPlacemark)
        
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = sourceMapItem
        directionsRequest.destination = destMapItem
        directionsRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionsRequest)
        directions.calculate { (response, error) in
            if let err = error
            {
                print(err.localizedDescription)
                return
            }
            
            guard let response = response
                else
            {
                print("Empty Response!!")
                return
            }
            guard let primaryRoute = response.routes.first else {
                print("response has no routes")
                return }
                    self.mapView.addOverlay(primaryRoute.polyline)
            
            //self.mapView.addOverlay(primaryRoute.polyline, level: .aboveRoads)
            
            self.mapView.setRegion(MKCoordinateRegion(primaryRoute.polyline.boundingMapRect), animated: true)
            
//            // initiate recursive animation
//            self.routeCoordinates = primaryRoute.polyline.coordinates
//            self.coordinateIndex = 0
            
            //below needed. DO NOT DELETE
            //primaryRoute.expectedTravelTime //use this to display the ETA
            
             self.steps = primaryRoute.steps
            
             for i in 0..<primaryRoute.steps.count
             {
                let step = primaryRoute.steps[i]
                
//                print(step.distance)
//                print(step.instructions)
//                print(step.polyline.coordinate)
                
                let region = CLCircularRegion(center: step.polyline.coordinate, radius: 20, identifier: "i")
                LocationManager.shared.locationManager.startMonitoring(for: region)
                
                let circle = MKCircle(center: region.center, radius: region.radius)
                self.mapView.addOverlay(circle)
             }
            
            let initialMsg = "In \(self.steps[0].distance) meters \(self.steps[0].instructions)"
            self.directionsLabel.text = initialMsg
        }
    }
    
    @objc func handleEnteredRegion(notification: Notification)
    {
        print("ENTERED")
        
    }
    
    @IBAction func btnOrderPickedTapped(_ sender: UIButton)
    {
    
    SocketIOManager.sharedInstance.emitOrderPicked(orderId!)
        btnOrderDelivered.isEnabled = true
        btnOrderDelivered.setTitleColor(#colorLiteral(red: 0.737254902, green: 0.1921568627, blue: 0.08235294118, alpha: 1), for: .normal)
        
        btnOrderPicked.isEnabled = false
        btnOrderPicked.setTitleColor(#colorLiteral(red: 0.6941176471, green: 0.537254902, blue: 0.5568627451, alpha: 1), for: .normal)
    }
    
    @IBAction func btnOrderDeliveredTapped(_ sender: UIButton)
    {
    SocketIOManager.sharedInstance.emitOrderDelivered(orderId!)
        performSegue(withIdentifier: "goToCompletion", sender: self)
        LocationManager.shared.stop()
    }
    
}

extension mapViewController: MKMapViewDelegate
{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        if overlay is MKPolyline
        {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
            renderer.lineWidth  = 2
            renderer.lineJoin = .round
            return renderer
        }
        
        if overlay is MKCircle
        {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
            renderer.fillColor  = #colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1)
            renderer.alpha = 0.5
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    
}
