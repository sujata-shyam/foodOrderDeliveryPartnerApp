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
    var currentLocation: CLLocation!
    
    override init()
    {
        locationManager = CLLocationManager()
        
        super.init()
        
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 5.0 // 20.0 meters
        locationManager.delegate = self //Calls didChangeAuthorization
    }
    
    func start()
    {
        locationManager.requestAlwaysAuthorization()
        
    }
    
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
        
        //locationManager.stopUpdatingLocation()

        //if let location = locations.last //For startUpdatingLocation()
        
        
        if let location = locations.first //For requestlocation()
        {
            //Below: Added on 4th Feb
            defaults.set("\(location.coordinate.latitude)", forKey: "initialLatitude")
            defaults.set("\(location.coordinate.longitude)", forKey: "initialLongitude")
            
            print("initialLatitude: \(location.coordinate.latitude)")
            print("initialLongitude: \(location.coordinate.longitude)")

            //Above: Added on 4th Feb
            
            //Below: Commented on 4th Feb
            /*  SocketIOManager.sharedInstance.emitLocationUpdate(dpLatitude: "\(location.coordinate.latitude)", dpLongitude: "\(location.coordinate.longitude)")

             */
            //Above: Commented on 4th Feb

            //For Testing
            //Spice Kitchen(GeekSkool)
            //SocketIOManager.sharedInstance.emitLocationUpdate(dpLatitude: "12.981264900000001", dpLongitude: "77.6461579")
//
            //Sway (Kalyan Nagar)
//            SocketIOManager.sharedInstance.emitLocationUpdate(dpLatitude: "13.020890300000001",dpLongitude: "77.643156")
//
            
            //Added on 7th Feb
            
            currentLocation = location
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
                    print("Core Location error:\(clErr.localizedDescription)")
            }
        }
        else
        {
            print("Error: ", error.localizedDescription)
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
        
        //locationManager.startUpdatingLocation() //Commented on 4th Feb
        locationManager.requestLocation()
    }
}
