import Foundation

@MainActor
class UpdateInv_Handler: ObservableObject {
    private var viewModel: UserManager
    private var profileViewModel: LoadCurrentUserModel
    private var user: DBUser?
    private var itemsListCopy: [Item]
    
    init() {
        // Ensure initialization happens on the main actor
        self.viewModel = UserManager()
        self.profileViewModel = LoadCurrentUserModel()
        self.itemsListCopy = []
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
    
//    func updateINV(listOfProductToOrder: [AnOrder], itemsListCopy: [Item]) -> Bool {
//        var mutableItemsListCopy = itemsListCopy
//        for order in listOfProductToOrder {
//            if !updateINVperOrder(with: order, itemsListCopy: &mutableItemsListCopy) {
//                return false
//            }
//        }
//        return true
//    }
//    
//    func updateINVperOrder(with order: AnOrder, itemsListCopy: inout[Item]) -> Bool {
//        let orderedProduct = order.productObj
//        for orderedItem in orderedProduct.requiredItemList {
//            if let index = itemsListCopy.firstIndex(where: { $0.name == orderedItem.name }) {
//                itemsListCopy[index].quantity -= orderedItem.quantity * order.quantity
//                // Ensure quantity doesn't go below zero
//                if itemsListCopy[index].quantity < 0 {
//                    return false
//                }
//            } else {
//                print("Item \(orderedItem.name) not found in inventory.")
//                // Handle the case where the item is not found in inventory
//            }
//        }
//        return true
//    }
    
    func updateINV(listOfProductToOrder: [AnOrder], itemsListCopy: [Item]) -> [Item]? {
        
        print(listOfProductToOrder)
        print("====================")
        print(itemsListCopy)
        
//        var mutableItemsListCopy = itemsListCopy
        self.itemsListCopy = itemsListCopy
        for order in listOfProductToOrder {
            if updateINVperOrder(with: order) {
                return nil
            }
        }
        return self.itemsListCopy
    }
    
    func updateINVperOrder(with order: AnOrder) -> Bool {
        let orderedProduct = order.productObj
        
        print("-----ORDERED PRODUCT------")
        print(orderedProduct)
        
        for orderedItem in orderedProduct.requiredItemList {
            if let index = self.itemsListCopy.firstIndex(where: { $0.name == orderedItem.name }) {
                self.itemsListCopy[index].quantity -= orderedItem.quantity * order.quantity
                // Ensure quantity doesn't go below zero
                if self.itemsListCopy[index].quantity < 0 {
                    return false
                }
            } else {
                print("Item \(orderedItem.name) not found in inventory.")
                // Handle the case where the item is not found in inventory
            }
        }
        return true
    }
}
