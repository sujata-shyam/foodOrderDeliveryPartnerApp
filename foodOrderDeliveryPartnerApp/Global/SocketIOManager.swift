import Foundation
import SocketIO

class SocketIOManager: NSObject
{
    static let sharedInstance = SocketIOManager()
    var socket:SocketIOClient!
    
    //let manager = SocketManager(socketURL: URL(string: "https://tummypolice.iyangi.com")!, config: [.log(true), .compress])
    //let manager = SocketManager(socketURL: URL(string: "https://tummypolice.iyangi.com")!, config: [.log(true),.forceWebsockets(true)])
    
    let manager = SocketManager(socketURL: URL(string: "https://tummypolice.iyangi.com")!, config: [.log(true)])

    override init()
    {
        super.init()
        socket = manager.defaultSocket
    }
    
    func establishConnection()
    {
        socket.connect()
//        socket.on(clientEvent: .connect) {data, ack in
//            print("Socket Connected!")
//
//            self.socket.on("new task") { data, ack in
//                print("new task:\(data)")
//            }
//        }
        
        socket.on(clientEvent: .connect) {data, ack in
            print("Socket Connected!")
            self.socket.on("new task") { data, ack in
                print("new task:\(data)")
                do
                {
                    print("Received New Task")
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let orderDetail = try JSONDecoder().decode([OrderDetail].self, from: jsonData)
                    print(orderDetail)
                    
                    if let orderID = orderDetail.first?.orderId
                    {
                        print("orderID:\(orderID)")
                        NotificationCenter.default.post(name: NSNotification.Name("gotOrderDetail"), object: orderDetail)
                    }
                }
                catch
                {
                    print(error)
                }
            }
        }
    }
   
    func closeConnection()
    {
        socket.disconnect()
        socket.on(clientEvent: .disconnect) {data, ack in
            print("Socket Disconnected!")
        }
    }
    
    func emitActiveDeliveryPartner(_ userId:String)
    {
        self.socket.emit("active delivery partner", userId)
    }
    
    func emitLocationUpdate(dpLatitude: String, dpLongitude: String)
    {
//        let dpLocation = [
//            "location" : [
//                "latitude": dpLatitude,
//                "longitude": dpLongitude
//            ]
//        ]
        
        let dpLocation = [
            "latitude": dpLatitude,
            "longitude": dpLongitude
        ]
        
        //self.socket.emit("update location", dpLocation)
        self.socket.emit("update location", dpLocation)

    }
    
//    func onNewTask()->String?
//    {
//        var localOrderId:String?
//
//            self.socket.on("new task") { data, ack in
//            print(data)
//        do
//        {
//            print("Received New Task")
//            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
//            let orderDetail = try JSONDecoder().decode([OrderDetail].self, from: jsonData)
//            print(orderDetail)
//
//            if let orderID = orderDetail.first?.orderId
//            {
//                print(orderID)
//                localOrderId = orderID
//            }
//        }
//        catch
//        {
//            print(error)
//        }
//        }
//        return localOrderId
//    }
    
    func onNewTask()->String?
    {
        var localOrderId:String?
        
        socket.on(clientEvent: .connect) {data, ack in
            
            self.socket.on("new task") { data, ack in
                print("new task:\(data)")
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
        }
        return localOrderId
    }
    
    func emitTaskAcception(_ orderId: String)
    {
        self.socket.emit("task accepted", orderId)
    }
    

    func emitOrderPicked(_ orderId: String)
    {
        print("emitOrderPicked")
        
        let details = [
            "orderId": orderId, "deliveryPartnerId": defaults.string(forKey: "userId")
        ]
        
        self.socket.emit("order pickedup", details)
    }
    
    func emitOrderDelivered(_ orderId: String)
    {
        print("emitOrderDelivered")
        
        let details = [
            "orderId": orderId, "deliveryPartnerId": defaults.string(forKey: "userId")
        ]
        socket.emit("order delivered", details)
    }
}
