import Foundation

@MainActor
class UpdateInv_Handler: ObservableObject {
    private var viewModel: UserManager
    private var profileViewModel: LoadCurrentUserModel
    private var user: DBUser?
    private var itemsListCopy: [Item]
    private var itemsListToDeduct: [Item]
    
    init() {
        // Ensure initialization happens on the main actor
        self.viewModel = UserManager()
        self.profileViewModel = LoadCurrentUserModel()
        self.itemsListCopy = []
        self.itemsListToDeduct = []
    }
    
    func changeItemsArrayInDB(user: DBUser, itemsListCopy: [Item]) async {
        do {
            let authDataResult = AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.getUser(userId: authDataResult!.uid)
            try await viewModel.setUpdateditemsArray(userId: (user.userId)!, newItemsList: itemsListCopy)
            
        } catch {
            print(error)
        }
    }
    
    func updateINV(listOfProductToOrder: [AnOrder], itemsListCopy: [Item]) -> [Item]? {
        self.itemsListCopy = itemsListCopy
        for order in listOfProductToOrder {
            if order.quantity != 0 && !(updateINVperOrder(with: order)) {
                return []
            }
        }
        self.itemsListToDeduct = self.itemsListCopy
        return self.itemsListToDeduct
    }
    
    func updateINVperOrder(with order: AnOrder) -> Bool {
        let orderedProduct = order.productObj
                
        for orderedItem in orderedProduct.requiredItemList {
            if let index = self.itemsListCopy.firstIndex(where: { $0.name == orderedItem.name }) {
                self.itemsListCopy[index].quantity -= orderedItem.quantity * order.quantity
                // Ensure quantity doesn't go below zero
                if self.itemsListCopy[index].quantity < 0 {
                    print("Item failed: ", self.itemsListCopy[index])
                    return false
                }
            } else {
                print("Item \(orderedItem.name) not found in inventory.")
            }
        }
        return true
    }
}
