import Foundation
import SocketIO

class SocketIOManager: NSObject
{
    static let sharedInstance = SocketIOManager()
    var socket:SocketIOClient!
    let manager = SocketManager(socketURL: URL(string: "https://tummypolice.iyangi.com")!, config: [.log(true), .compress])

    override init()
    {
        super.init()
        socket = manager.defaultSocket
    }
    
    //Function to establish the socket connection with your server. Generally you want to call this method from your `Appdelegate` in the `applicationDidBecomeActive` method.
    func establishConnection()
    {
        socket.connect()
        print("Socket Connected!")
    }
   
    //Function to close established socket connection. Call this method from `applicationDidEnterBackground` in your `Appdelegate` method.
    func closeConnection()
    {
        socket.disconnect()
        print("Socket Disconnected!")
    }
    
//    func establishConnection()
//    {
//        self.socket.on(clientEvent: .connect) { (data, ack) in
//            print(data)
//            print("Socket connected")
//
//
//            SocketIOManager.sharedInstance.emitActiveDeliveryPartner(defaults.string(forKey: "userId")!)
//
////            SocketIOManager.sharedInstance.emitLocationUpdate(dpLatitude:
////            "\(LocationManager.shared.locationManager.location?.coordinate.latitude)", dpLongitude: "\(LocationManager.shared.locationManager.location?.coordinate.longitude)")
//
//
//
//
////            SocketIOManager.sharedInstance.emitLocationUpdate(dpLatitude: "13.020890300000001",dpLongitude: "77.643156")
////
//            //print(defaults.string(forKey: "userId")!)
//            //LocationManager.shared.retrieveCurrentLocation()
//
//            //for spice curry
//            SocketIOManager.sharedInstance.emitLocationUpdate(dpLatitude: "12.981264900000001", dpLongitude: "77.6461579")
//
//
//
//            //self.socket.emit("active delivery partner", (defaults.string(forKey: "userId")!))
//
////            _ = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { timer in
////
////                //For Testing
////                //Spice Kitchen(GeekSkool)
////                print("TIMER")
////                SocketIOManager.sharedInstance.emitLocationUpdate(dpLatitude: "12.981264900000001", dpLongitude: "77.6461579")
////            }
//
////            LocationManager.shared.retrieveCurrentLocation()
//            self.onNewTask()
//        }
//        socket.connect()
//    }
    
    //    func closeConnection()
    //    {
    //        socket.on("disconnect") {data, ack in
    //            print("socket disconnected")
    //        }
    //        socket.disconnect()
    //    }

    func emitActiveDeliveryPartner(_ userId:String)
    {
        self.socket.emit("active delivery partner", userId)
    }
    
    func emitLocationUpdate(dpLatitude: String, dpLongitude: String)
    {
        let dpLocation = [
            "location" : [
                "latitude": dpLatitude,
                "longitude": dpLongitude
            ]
        ]
        self.socket.emit("update location", dpLocation)
    }
    
//    func emitLocationUpdate(dpLatitude: String, dpLongitude: String)
//    {
////        self.socket.on(clientEvent: .ping) { (_, _) in
////                        print("PING")
////
//////                        let dpLocation = [
//////                            "location" : [
//////                                "latitude": String((locationManager.location?.coordinate.latitude)!),
//////                                "longitude": String((locationManager.location?.coordinate.longitude)!)
//////                            ]
//////                        ]
////
////            let dpLocation = [
////                "location" : [
////                    "latitude": dpLatitude,
////                    "longitude": dpLongitude
////                ]
////            ]
////                        self.socket.emit("update location", dpLocation)
////                    }
//
//
//        let dpLocation = [
//            "location" : [
//                "latitude": dpLatitude,
//                "longitude": dpLongitude
//            ]
//        ]
//        self.socket.emit("update location", dpLocation)
//    }
    
    func onNewTask()->String?
    {
        var localOrderId:String?

        self.socket.on("new task") { data, ack in
        print(data)
        do
        {
            print("Received New Task")
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            let orderDetail = try JSONDecoder().decode([OrderDetail].self, from: jsonData)
            print(orderDetail)
            
            if let orderID = orderDetail.first?.orderId
            {
                print(orderID)
                localOrderId = orderID
            }
        }
        catch
        {
            print(error)
        }
        }
        return localOrderId
    }
    
    func emitTaskAcception(_ orderId: String)
    {
        self.socket.emit("task accepted", orderId)
    }
    
    func emitOrderPicked()
    {
        self.socket.emit("order pickedup")
    }
    
    func emitOrderDelivered()
    {
        socket.emit("order delivered")
    }
}
