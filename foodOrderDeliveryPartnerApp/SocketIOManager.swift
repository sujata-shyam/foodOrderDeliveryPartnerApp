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
    
    func establishConnection()
    {
        socket.connect()
        print("Socket Connected!")
    }
   
    func closeConnection()
    {
        socket.disconnect()
        print("Socket Disconnected!")
    }
    
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
