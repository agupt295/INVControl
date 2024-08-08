import Foundation

@MainActor
class InventoryStatus_Handler: ObservableObject {
    private var viewModel: UserManager
    private var profileViewModel: LoadCurrentUserModel
    private var user: DBUser?
    
    init() {
        // Ensure initialization happens on the main actor
        self.viewModel = UserManager()
        self.profileViewModel = LoadCurrentUserModel()
    }
    
//    func addItem(user: DBUser, newItemName: String, newItemQuantity: Int) async throws -> DBUser {
//        let newItem = Item(name: newItemName, quantity: newItemQuantity)
//        try await viewModel.addItemList(userId: (user.userId)!, newItem: newItem)
//        self.user = try await profileViewModel.loadCurrentUser()
//
//        return self.user!
//    }
}

// Model to represent a Product Count within a Category
struct CategoryProductCount: Codable, Hashable {
    let category: String
    var productCounts: [String: String] = [:] // Product name to count
}
