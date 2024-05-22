import SwiftUI

struct UpdateInvView: View {
    @StateObject private var userManager = UserManager()
    @StateObject private var profileViewModel = LoadCurrentUserModel()
    @StateObject private var viewModel = UpdateInv_Handler()
    @State private var listOfProductToOrder: [AnOrder] = []
    @State private var productArray: [Product] = []
    @State private var itemsListCopy: [Item] = []
    @State private var updateStatus_text: String = ""
    @State private var user: DBUser? = nil
    @State private var showAlert = false
    @State private var updateStatus = false
    @State private var isProfileSheetPresented = false
    @State private var isLoading = true
    
    var body: some View {
        if isLoading {
            VStack {
                Text("Loading...")
                Text("Retrieving Data From Database...")
            }
            .onAppear {
                Task {
                    self.user = try await profileViewModel.loadCurrentUser()
                    productArray = user!.productList
                    itemsListCopy = user!.itemList
                    
                    listOfProductToOrder = {
                        return productArray.map { product in
                            return AnOrder(productObj: product, quantity: 0)
                        };
                    }()
                    
                    isLoading = false
                }
            }
            
        } else {
            NavigationView {
                VStack {
                    List {
                        ForEach(productArray.indices, id: \.self) { index in
                            HStack {
                                Text(productArray[index].name)
                                Spacer()
                                Stepper(value: $listOfProductToOrder[index].quantity, in: 0...10) {
                                    Text(String(repeating: " ", count: 20) + "Qty: \(listOfProductToOrder[index].quantity)")
                                }
                            }
                        }
                    }
                    .toolbar {
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                isProfileSheetPresented.toggle()
                            }) {
                                Image(systemName: "person.crop.circle.fill")
                            }
                        }
                    }
                    
                    Button(action: {
                        showAlert = true
                    }) {
                        Text("Place Order")
                    }
                    
                    .foregroundStyle(Color(.red))
                    .cornerRadius(5)
                    
                    Spacer()
                }
                .navigationTitle("Make Orders")
                .sheet(isPresented: $isProfileSheetPresented) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 100))
                    
                    ProfileView()
                        .background(Color.red.ignoresSafeArea())
                }
                .alert(isPresented: $showAlert) {
                    
                    Alert(
                        title: Text("Confirm Order"),
                        message: Text("Are you sure you want to place this order?"),
                        primaryButton: .default(Text("Update Inventory").foregroundStyle(Color(.red))) {
                            
                            Task {
                                do {
                                    if let updatedItemsListCopy = viewModel.updateINV(listOfProductToOrder: listOfProductToOrder, itemsListCopy: itemsListCopy) {
//                                        await changeItemsArrayInDB(itemsListCopy: itemsListCopy)
                                        await viewModel.changeItemsArrayInDB(user: self.user!, itemsListCopy: updatedItemsListCopy)
                                        print("Items deducted from your inventory!")
                                    } else {
                                        print("Insufficient Stocks!")
                                    }
                                }
                            }
                        },
                        secondaryButton: .cancel(
                            Text("Cancel").foregroundStyle(Color(.red))
                        )
                    )
                }
            }
            .task{
                do {
                    self.user = try await profileViewModel.loadCurrentUser()
                    productArray = user!.productList
                    itemsListCopy = user!.itemList
                    
                    listOfProductToOrder = {
                        return productArray.map { product in
                            return AnOrder(productObj: product, quantity: 0)
                        };
                    }()
                } catch {
                    print(error)
                }
            }
        }
    }
    
//    func changeItemsArrayInDB(itemsListCopy: [Item]) async {
//        do {
//            let authDataResult = AuthenticationManager.shared.getAuthenticatedUser()
//            self.user = try await UserManager.shared.getUser(userId: authDataResult!.uid)
//            try await userManager.setUpdateditemsArray(userId: (user?.userId)!, newItemsList: itemsListCopy)
//        } catch {
//            print(error)
//        }
//    }
//    
//    func updateINV(listOfProductToOrder: [AnOrder]) -> Bool {
//        for order in listOfProductToOrder {
//            if !viewModel.updateINVperOrder(with: order, itemsListCopy: itemsListCopy) {
//                return false
//            }
//        }
//        return true
//    }
//    
//    func updateINVperOrder(with order: AnOrder, itemsListCopy:[Item]) -> Bool {
//        let orderedProduct = order.productObj
//        for orderedItem in orderedProduct.requiredItemList {
//            if let index = itemsListCopy.firstIndex(where: { $0.name == orderedItem.name }) {
//                self.itemsListCopy[index].quantity -= orderedItem.quantity * order.quantity
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
}