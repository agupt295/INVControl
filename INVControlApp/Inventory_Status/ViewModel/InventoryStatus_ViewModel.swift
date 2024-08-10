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
    
    func addManufacturedProduct(user: DBUser, category: String, productList: [String: String]) async throws -> DBUser {
        let newManufacturedProduct = CategoryProductCount(category: category, productCounts: productList)
        try await viewModel.addManufacturedProducts(userId: (user.userId)!, manufacturedSet: newManufacturedProduct)
        self.user = try await profileViewModel.loadCurrentUser()
        return self.user!
    }
    
    func setManufacturedProduct(user: DBUser, index: Int, item: String, updatedQuantity: String) async throws -> DBUser {
//        if(index == -1) { // adding new product
////            let newManufacturedProduct = CategoryProductCount(category: category, productCounts: productList)
//            
//        }
        try await viewModel.setManufacturedProducts(userId: (user.userId)!, index: index, item: item, updatedQuantity: updatedQuantity)
        self.user = try await profileViewModel.loadCurrentUser()
        return self.user!
    }
}

// Model to represent a Product Count within a Category
struct CategoryProductCount: Codable, Hashable {
    let category: String
    var productCounts: [String: String] = [:] // Product name to count
}
