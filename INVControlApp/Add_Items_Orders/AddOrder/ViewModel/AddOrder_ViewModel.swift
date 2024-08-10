import Foundation

@MainActor
class AddOrder_Handler: ObservableObject {
    private var viewModel: UserManager
    private var profileViewModel: LoadCurrentUserModel
    private var user: DBUser?
    
    init() {
        // Ensure initialization happens on the main actor
        self.viewModel = UserManager()
        self.profileViewModel = LoadCurrentUserModel()
    }
    
    func addProduct(user: DBUser, orderName: String, category: String, itemsArrayCopy: [Item]) async throws -> DBUser {
        let newProduct = Product(name: orderName, requiredItemList: itemsArrayCopy.filter { $0.quantity > 0 }, category: category)
        try await viewModel.addProductList(userId: (user.userId)!, newProduct: newProduct)
        self.user = try await profileViewModel.loadCurrentUser()
        
        return self.user!
    }
}
