import Foundation

@MainActor
class AddItem_Handler: ObservableObject {
    private var viewModel: UserManager
    private var profileViewModel: LoadCurrentUserModel
    private var user: DBUser?
    
    init() {
        // Ensure initialization happens on the main actor
        self.viewModel = UserManager()
        self.profileViewModel = LoadCurrentUserModel()
    }
    
    func addItem(user: DBUser, newItemName: String, newItemQuantity: Int) async throws -> DBUser {
        let newItem = Item(name: newItemName, quantity: newItemQuantity)
        try await viewModel.addItemList(userId: (user.userId)!, newItem: newItem)
        self.user = try await profileViewModel.loadCurrentUser()

        return self.user!
    }
}
