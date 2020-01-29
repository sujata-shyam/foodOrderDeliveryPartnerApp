import Foundation
import SocketIO

class SocketIOManager: NSObject
{
    static let sharedInstance = SocketIOManager()

    var socket:SocketIOClient!

    // defaultNamespaceSocket and swiftSocket both share a single connection to the server
    let manager = SocketManager(socketURL: URL(string: "https://tummypolice.iyangi.com")!, config: [.log(true), .compress])

    override init()
    {
        super.init()
        socket = manager.defaultSocket
    }
    
    
    
    // MARK: Socket connection open
    func establishConnection()
    {
        self.socket.on(clientEvent: .connect) { (data, ack) in
            print(data)
            print("Socket connected")
            
            //self.socket.emit("active delivery partner", (defaults.string(forKey: "userId")!))
        }
        socket.connect()
    }
    
    // MARK: Socket connection close
    func closeConnection()
    {
        socket.on("disconnect") {data, ack in
            print("socket disconnected")
        }
        socket.disconnect()
    }
    
    func emitActiveDeliveryPartner(_ userId:String)
    {
        //self.socket.emit("active delivery partner", (defaults.string(forKey: "userId")!))
//        socket?.emitWithAck("active delivery partner", userId).timingOut(after: 0) {data in
//            print(data)
//        }
        self.socket.emit("active delivery partner", userId)

    }
    
    func emitLocationUpdate(dpLatitude: String, dpLongitude: String)
    {
//        self.socket.on(clientEvent: .ping) { (_, _) in
//                        print("PING")
//
////                        let dpLocation = [
////                            "location" : [
////                                "latitude": String((locationManager.location?.coordinate.latitude)!),
////                                "longitude": String((locationManager.location?.coordinate.longitude)!)
////                            ]
////                        ]
//
//            let dpLocation = [
//                "location" : [
//                    "latitude": dpLatitude,
//                    "longitude": dpLongitude
//                ]
//            ]
                        //self.socket.emit("update location", dpLocation)
 //                   }
        
        
        let dpLocation = [
            "location" : [
                "latitude": dpLatitude,
                "longitude": dpLongitude
            ]
        ]
        self.socket.emit("update location", dpLocation)
    }
    
    func onNewTask()->String?
    {
        var localOrderId:String?

        self.socket.on("new task") { data, ack in
        print(data)
            
        do
        {
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
