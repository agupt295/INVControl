import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

@MainActor
final class LoadCurrentUserModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws -> DBUser {
        do {
            let authDataResult = AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.getUser(userId: authDataResult!.uid)
            return self.user!
        } catch {
            print(error)
        }
        return self.user!
    }
}

enum ItemType: String, Codable {
    case liquidOrPowder
    case solids
}

struct Item: Codable, Identifiable, Hashable {
    var id = UUID() // for Identifiable
    var name: String
    var quantity: Double
    var type: ItemType
    
    var status: String {
        return quantity > 2 ? "🟢" : "🔴"
    }
}

struct Product: Codable, Identifiable {
    var id = UUID()
    var name: String
    var requiredItemList: [Item]
    var category: String
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
    var manufactured_product_List: [CategoryProductCount]
}

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
    
    func addManufacturedProducts(userId: String, manufacturedSet: CategoryProductCount) async throws {
        var user = try await getUser(userId: userId)
        user.manufactured_product_List.append(manufacturedSet)
        try userDocument(userId: userId).setData(from: user)
    }
    
    func setManufacturedProducts(userId: String, index: Int, item: String, updatedQuantity: String) async throws {
        var user = try await getUser(userId: userId)
//      categoryProductCounts[index].productCounts[selectedItem] = itemQuantity
        user.manufactured_product_List[index].productCounts[item] = updatedQuantity
        try userDocument(userId: userId).setData(from: user)
    }
}
