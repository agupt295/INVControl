import SwiftUI

@MainActor
final class SignInEmailViewModel: ObservableObject {
    func signIn(email: String, password: String, username: String, warehouseLocation: String) async -> Bool{
        do{
            let returedUserData = try await AuthenticationManager.shared.createuser(email: email, password: password)
            let userInfo = DBUser(userId: returedUserData.uid, email: email, username: username, password: password, itemList: [], productList: [], warehouseLocation: warehouseLocation)
            try await UserManager.shared.createNewUser(user: userInfo)
            
            return true
        } catch {
            print("Error: \(error)")
            return false
        }
    }
    
    func login(email: String, password: String) async -> Bool {
        do{
            _ = try await AuthenticationManager.shared.Login(email: email, password: password)
            return true
            
        } catch {
            print("{ERROR}: \(error)")
            return false
        }
    }
}

// All Seperate Items a User can add -- SAMPLE DATA
var itemArray: [Item] = [
    Item(name: "Item 1", quantity: 5),
    Item(name: "Item 2", quantity: 5),
    Item(name: "Item 3", quantity: 5),
    Item(name: "Item 4", quantity: 5),
    Item(name: "Item 5", quantity: 5),
    Item(name: "Item 6", quantity: 5),
    Item(name: "Item 7", quantity: 5),
    Item(name: "Item 8", quantity: 5),
    Item(name: "Item 9", quantity: 5)
]

// Copy of the itemArray only quantity = 0
var zeroitemArray = itemArray.map { Item(name: $0.name, quantity: 0) }

// Each Oredr contains a list of [Item]
struct Order: Identifiable {
    let id = UUID()
    var name: String = ""
    var itemList: [Item]
    
    init(name: String, items: [Item]) {
        self.name = name
        self.itemList = items
    }
}

// All the Orders a User can have
struct OrderList: Identifiable {
    let id = UUID()
    var orders: [Order]
}

// All Orders made by the user -- SAMPLE DATA
var orderList: OrderList = OrderList(orders: [
    Order(name: "Order 1", items: [
        Item(name: "Item 1", quantity: 5),
        Item(name: "Item 8", quantity: 10)
    ]),
    Order(name: "Order 2", items: [
        Item(name: "Item 3", quantity: 7),
        Item(name: "Item 4", quantity: 3)
    ]),
    Order(name: "Order 3", items: [
        Item(name: "Item 6", quantity: 2),
        Item(name: "Item 9", quantity: 8)
    ])
])

// This is just an array that stores 1 Order and its Quantity
struct SpecificProductOrdered: Identifiable {
    let id = UUID()
    var order: Order
    var quantity: Int
    
    init(order: Order, quantity: Int) {
        self.order = order
        self.quantity = quantity
    }
}

func initializeAllProductOrderedList(from orderList: OrderList) -> [SpecificProductOrdered] {
    var allProductOrderedList: [SpecificProductOrdered] = []
    
    for order in orderList.orders {
        let specificProductOrdered = SpecificProductOrdered(order: order, quantity: 0)
        allProductOrderedList.append(specificProductOrdered)
    }
    
    return allProductOrderedList
}

// This is List of [SpecificProductOrdered] that stores a List of [Orders] and their Quantity
var AllProductOrderedList = initializeAllProductOrderedList(from: orderList)
