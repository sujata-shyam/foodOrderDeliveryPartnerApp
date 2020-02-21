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
        if let location = locations.last
        {
            currentLocation = location
            
            SocketIOManager.sharedInstance.emitLocationUpdate(dpLatitude: "\(location.coordinate.latitude)", dpLongitude:"\(location.coordinate.longitude)")
            
            if(timerStarted == false)
            {
                timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { timer in
                    SocketIOManager.sharedInstance.emitLocationUpdate(dpLatitude: "\(location.coordinate.latitude)", dpLongitude:"\(location.coordinate.longitude)")
                }
                timerStarted = true
            }
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
        
        locationManager.startUpdatingLocation()
        //locationManager.requestLocation()
    }
}
