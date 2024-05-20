import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Item: Codable, Identifiable {
    var id = UUID() // for Identifiable
    var name: String
    var quantity: Int
    
    var status: String {
        return quantity > 2 ? "🟢" : "🔴"
    }
}

struct Product: Codable, Identifiable {
    var id = UUID()
    var name: String
    var requiredItemList: [Item]
}

struct AnOrder: Codable, Identifiable {
    var id = UUID()
    var productObj: Product
    var quantity: Int
}

struct DBUser: Codable {
    let userId: String?
    let email: String?
    let username: String?
    let password: String?
    var itemList: [Item]
    var productList: [Product]
    var warehouseLocation: String?
}

let states = ["Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa"]


final class UserManager: ObservableObject {
    
    static let shared = UserManager()
    
    private let userCollection = Firestore.firestore().collection("Users")
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId!).setData(from: user, merge: false)
    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
    func addItemList(userId: String, newItem: Item) async throws {
        var user = try await getUser(userId: userId)
        user.itemList.append(newItem)
        try userDocument(userId: userId).setData(from: user)
    }
    
    func addProductList(userId: String, newProduct: Product) async throws {
        var user = try await getUser(userId: userId)
        user.productList.append(newProduct)
        try userDocument(userId: userId).setData(from: user)
    }
    
    func setUpdateditemsArray(userId: String, newItemsList: [Item]) async throws {
        var user = try await getUser(userId: userId)
        user.itemList = newItemsList
        try userDocument(userId: userId).setData(from: user)
    }
    
}
