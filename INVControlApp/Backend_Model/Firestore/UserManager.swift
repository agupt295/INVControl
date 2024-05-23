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

//@MainActor
//final class SignInEmailViewModel: ObservableObject {
//    func signIn(email: String, password: String, username: String) async -> Bool{
//        do{
//            let returedUserData = try await AuthenticationManager.shared.createuser(email: email, password: password)
//            let userInfo = DBUser(userId: returedUserData.uid, email: email, username: username, password: password, itemList: [], productList: [])
//            try await UserManager.shared.createNewUser(user: userInfo)
//            return true
//            
//        } catch {
//            print("Error: \(error)")
//            return false
//        }
//    }
//    
//    func login(email: String, password: String) async -> Bool {
//        do{
//            _ = try await AuthenticationManager.shared.Login(email: email, password: password)
//            return true
//            
//        } catch {
//            print("{ERROR}: \(error)")
//            return false
//        }
//    }
//}

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
}
