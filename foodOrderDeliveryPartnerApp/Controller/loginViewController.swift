//
//  ViewController.swift
//  foodOrderDeliveryPartnerApp
//
//  Created by Sujata on 14/01/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import UIKit
import CoreLocation

class loginViewController: UIViewController
{
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var viewLogin: UIView!
    
    //let locationManager = CLLocationManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setTitleLabelUI()
        setViewLogin()
        setTextDelegate()
        
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestAlwaysAuthorization()
        
       
        
        LocationManager.shared.start()
    }

    func setTitleLabelUI()
    {
        lblTitle.layer.cornerRadius = 10
        lblTitle.layer.masksToBounds = true
        lblTitle.layer.borderWidth = 2
        lblTitle.layer.borderColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
    }
    
    func setViewLogin()
    {
        viewLogin.layer.cornerRadius = 10
        viewLogin.layer.masksToBounds = true
        viewLogin.layer.borderWidth = 2
        viewLogin.layer.borderColor = #colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)
    }
    
    func setTextDelegate()
    {
        txtPhone.delegate = self
        txtPassword.delegate = self
    }
    
    func clearUIFields()
    {
        self.txtPhone.text = nil
        self.txtPassword.text = nil
    }
    
    @IBAction func unwindTologinVC(segue:UIStoryboardSegue)
    {}
    
    @IBAction func btnLoginTapped(_ sender: UIButton)
    {
        if(txtPhone.text!.isEmpty || txtPassword.text!.isEmpty)
        {
            displayAlert(vc: self, title: "", message: "Please enter the details.")
        }
        else
        {
            loadLoginData(txtPhone.text!)
        }
        txtPhone.resignFirstResponder()
    }
    
    func loadLoginData(_ txtPhone: String)
    {
        let searchURL = URL(string: "https://tummypolice.iyangi.com/api/v1/deliverypartner/login")
        var searchURLRequest = URLRequest(url: searchURL!)
        
        searchURLRequest.httpMethod = "POST"
        searchURLRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do
        {
            let jsonBody = try JSONEncoder().encode(LoginRequest(id: txtPhone))
            searchURLRequest.httpBody = jsonBody
        }
        catch
        {
            print(error)
        }
        
        URLSession.shared.dataTask(with: searchURLRequest){ data, response,error in
            guard let data =  data else { return }
            
            do
            {
                guard let response = response as? HTTPURLResponse,
                    (200...299).contains(response.statusCode)
                    else {
                        print(error as Any)
                        return
                }
                let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)


                if loginResponse.id != nil
                {
                    if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                        CLLocationManager.authorizationStatus() == .authorizedAlways)
                    {
                        self.saveUserDetailsLocally(loginResponse)
                   
                        if(SocketIOManager.sharedInstance.socket.status == .connected)
                        {
                           //LocationManager.shared.request()
                       SocketIOManager.sharedInstance.emitActiveDeliveryPartner(loginResponse.id!)
                        }
                        else
                        {
                            SocketIOManager.sharedInstance.establishConnection()
                         SocketIOManager.sharedInstance.emitActiveDeliveryPartner(loginResponse.id!)
                        }
                    
                        DispatchQueue.main.async
                        {
                            self.clearUIFields()
                            self.performSegue(withIdentifier: "goToOrderDetails", sender: self)
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async
                        {
                            displayAlertForSettings()
                        }
                    }
                }
                else
                {
                    DispatchQueue.main.async
                    {
                        displayAlert(vc: self, title: "Failed Login Attempt", message: "Login ID does not exist")
                    }
                }
            }
            catch
            {
                print(error)
            }
        }.resume()
    }
    
    func saveUserDetailsLocally(_ loginResponse: LoginResponse)
    {
        defaults.set(loginResponse.msg, forKey: "userMessage")
        defaults.set(loginResponse.session, forKey: "userSession")
        defaults.set(loginResponse.id, forKey: "userId")
        defaults.set(loginResponse.phone, forKey: "userPhone")
        defaults.set(true, forKey: "isUserLoggedIn")
    }
}

extension loginViewController:UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}

//extension loginViewController:CLLocationManagerDelegate
//{
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
//    {
//        retrieveCurrentLocation()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
//    {
//        if let location = locations.last
//        {
//            SocketIOManager.sharedInstance.onLocationUpdate(dpLatitude: "\(location.coordinate.latitude)", dpLongitude: "\(location.coordinate.longitude)")
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
//    {
//        if let clErr = error as? CLError
//        {
//            switch clErr
//            {
//            case CLError.locationUnknown:
//                print("Error Location Unknown")
//            case CLError.denied:
//                displayAlertForSettings()
//            default:
//                print("other Core Location error")
//            }
//        }
//        else
//        {
//            print("other error:", error.localizedDescription)
//        }
//    }
//
//    func retrieveCurrentLocation()
//    {
//        let status = CLLocationManager.authorizationStatus()
//
//        if(status == .denied || status == .restricted || !CLLocationManager.locationServicesEnabled())
//        {
//            displayAlertForSettings()
//            return
//        }
//
//        if(status == .notDetermined)
//        {
//            locationManager.requestAlwaysAuthorization()
//            return
//        }
//
//        locationManager.startUpdatingLocation()
//    }
//
//    func displayAlertForSettings()
//    {
//        let alertController = UIAlertController (title: "The app needs access to your location to function.", message: "Go to Settings?", preferredStyle: .alert)
//
//        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
//            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
//                return
//            }
//
//            if UIApplication.shared.canOpenURL(settingsUrl) {
//                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
//                    print("Settings opened: \(success)") // Prints true
//                })
//            }
//        }
//        alertController.addAction(settingsAction)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//        alertController.addAction(cancelAction)
//
//        present(alertController, animated: true, completion: nil)
//    }
//}
