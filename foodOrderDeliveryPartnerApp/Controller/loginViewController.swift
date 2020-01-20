//
//  ViewController.swift
//  foodOrderDeliveryPartnerApp
//
//  Created by Sujata on 14/01/20.
//  Copyright © 2020 Sujata. All rights reserved.
//

import UIKit
//import SocketIO
import CoreLocation

class loginViewController: UIViewController
{
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
//    let manager = SocketManager(socketURL: URL(string: "https://tummypolice.iyangi.com")!, config: [.log(true), .compress])
//    var socket:SocketIOClient!
    //let locationManager = CLLocationManager()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setTitleLabelUI()
        setTextDelegate()
        
        locationManager.requestAlwaysAuthorization()
        //getCurrentLocation()
    }

    func setTitleLabelUI()
    {
        lblTitle.layer.cornerRadius = 10
        lblTitle.layer.masksToBounds = true
    }
    
//    func getCurrentLocation()
//    {
//
//        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
//            CLLocationManager.authorizationStatus() == .authorizedAlways)
//        {
//
//            print(locationManager.location?.coordinate.latitude)
//            print(locationManager.location?.coordinate.longitude)
//        }
//    }
    
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
//                    self.socket = self.manager.defaultSocket
                    
                    if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                        CLLocationManager.authorizationStatus() == .authorizedAlways)
                    {
                        //self.setSocketEvents(loginResponse.id!)
                        //self.closeSocketConnection()
                        
                        self.saveUserDetailsLocally(loginResponse)
                        
                        DispatchQueue.main.async
                        {
                            //displayAlert(vc: self, title: "", message: "Login Successful")
                           
                            self.clearUIFields()
                            
                            self.performSegue(withIdentifier: "goToOrderDetails", sender: self)
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async
                        {
                            self.displayAlertForSettings()
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
    
    func displayAlertForSettings()
    {
        let alertController = UIAlertController (title: "The app needs access to your location to function.", message: "Go to Settings?", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
   
    
    
//    //MARK:- Socket functions
//    
//    private func setSocketEvents(_ deliveryPersonId:String)
//    {
//        self.socket.on(clientEvent: .connect) { (data, ack) in
//            print(data)
//            print("Socket connected")
//            self.socket.emit("active delivery partner", deliveryPersonId)
//            
//            let dpLocation = [
//                "location" : [
//                    "latitude": self.locationManager.location?.coordinate.latitude,
//                    "longitude": self.locationManager.location?.coordinate.longitude,
//                ]
//            ]
//            self.socket.emit("updateUserInfo", dpLocation)
//            
//
//            //if let newLocation = self.location
//            //{
//                //self.socket.emit("update location", with: newLocation)
//                //self.socket.emit("update location", "newLocation")
//                //socket.emit("myEvent", CustomData(name: "Erik", age: 24))
//                //self.socket.emit("update location", newLocation)
//            //}
//            
//            
//        }
//        
//        self.socket.on("new task") { data, ack in
//            print(data)
//        }
//    
//        self.socket.connect()
//    }
//    
//    private func closeSocketConnection() {
//        self.socket.disconnect()
//    }
}

extension loginViewController:UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}
