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
        
        socket.on(clientEvent: .connect) {data, ack in
            print("Socket Connected!")
            self.socket.on("new task") { data, ack in
                do
                {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                    let orderDetail = try JSONDecoder().decode([OrderDetail].self, from: jsonData)
                    
                    if let _ = orderDetail.first?.orderId
                    {
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
        let dpLocation = [
            "latitude": dpLatitude,
            "longitude": dpLongitude
        ]
        self.socket.emit("update location", dpLocation)
    }
    
    func emitTaskAcception(_ orderId: String)
    {
        self.socket.emit("task accepted", orderId)
    }
    
    func emitOrderPicked(_ orderId: String)
    {
        let details = [
            "orderId": orderId, "deliveryPartnerId": defaults.string(forKey: "userId")
        ]
        
        self.socket.emit("order pickedup", details)
    }
    
    func emitOrderDelivered(_ orderId: String)
    {
        let details = [
            "orderId": orderId, "deliveryPartnerId": defaults.string(forKey: "userId")
        ]
        socket.emit("order delivered", details)
    }
}
