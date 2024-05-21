import SwiftUI

@MainActor
final class SignInEmailViewModel: ObservableObject {
    func signIn(email: String, password: String, username: String) async -> Bool{
        do{
            let returedUserData = try await AuthenticationManager.shared.createuser(email: email, password: password)
            let userInfo = DBUser(userId: returedUserData.uid, email: email, username: username, password: password, itemList: [], productList: [])
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

// Each Order contains a list of [Item]
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
