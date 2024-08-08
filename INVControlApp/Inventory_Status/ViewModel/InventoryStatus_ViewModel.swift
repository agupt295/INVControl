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
}

// Model to represent a Product Count within a Category
struct CategoryProductCount: Codable, Hashable {
    let category: String
    var productCounts: [String: Int] = [:] // Product name to count
}

struct Product_with_Item_Count: Codable, Identifiable, Hashable {
    var id = UUID()
    let name: String
    let category: String
    var requiredItemList: [Item_Count]
}

struct Item_Count: Codable, Identifiable, Hashable {
    var id = UUID()
    let name: String
    var quantity: Int
}

// Function to get product counts grouped by category
func getCategoryProductCounts(products: [Product_with_Item_Count]) -> [CategoryProductCount] {
        var categoryCounts: [String: [String: Int]] = [:]
        
        for product in products {
            if categoryCounts[product.category] == nil {
                categoryCounts[product.category] = [:]
            }
            categoryCounts[product.category]?[product.name] = product.requiredItemList.reduce(0) { $0 + $1.quantity }
        }
        
        return categoryCounts.map { CategoryProductCount(category: $0.key, productCounts: $0.value) }
    }
