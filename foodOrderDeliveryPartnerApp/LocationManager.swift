//
//  LocationManager.swift
//  foodOrderDeliveryPartnerApp
//
//  Created by Sujata on 28/01/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject, CLLocationManagerDelegate
{
    static let shared = LocationManager()
    let locationManager : CLLocationManager
    
    override init()
    {
//        if (CLLocationManager.locationServicesEnabled())
//        {
        
        locationManager = CLLocationManager()
        
        //added on 29th Jan
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 20.0 // 20.0 meters
        //added on 29th Jan

        super.init()
        locationManager.delegate = self
//        }
//        else
//        {
//            #if debug
//            println("Location services are not enabled");
//            #endif
//        }
        
        
        
    }
    
    func start()
    {
        locationManager.requestAlwaysAuthorization()
    }
    
//    func request()
//    {
//        locationManager.requestLocation()
//    }
    
    func stop()
    {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        retrieveCurrentLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        //if let location = locations.last //For startUpdatingLocation()
        if let location = locations.first //For requestlocation()
        {
            SocketIOManager.sharedInstance.emitLocationUpdate(dpLatitude: "\(location.coordinate.latitude)", dpLongitude: "\(location.coordinate.longitude)")
        
            //Spice Kitchen(GeekSkool)
//            SocketIOManager.sharedInstance.emitLocationUpdate(dpLatitude: "12.981264900000001", dpLongitude: "77.6461579")
//
            //Sway (Kalyan Nagar)
//            SocketIOManager.sharedInstance.emitLocationUpdate(dpLatitude: "13.020890300000001",, dpLongitude: "77.643156")
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        if let clErr = error as? CLError
        {
            switch clErr
            {
            case CLError.locationUnknown:
                print("Error Location Unknown")
            case CLError.denied:
                displayAlertForSettings()
            default:
                print("other Core Location error")
            }
        }
        else
        {
            print("other error:", error.localizedDescription)
        }
        locationManager.stopUpdatingLocation()
    }
    
    func retrieveCurrentLocation()
    {
        let status = CLLocationManager.authorizationStatus()
        
        if(status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled())
        {
            displayAlertForSettings()
            return
        }
        
        if(status == .notDetermined)
        {
            locationManager.requestAlwaysAuthorization()
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
}
