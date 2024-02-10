import SwiftUI

struct AddItemView: View {
    @StateObject private var viewModel = UserManager()
    @StateObject private var profileViewModel = ProfileViewModel()
    
    @State private var isAddItemSheetPresented = false
    @State private var isProfileSheetPresented = false
    @State private var newItemName = ""
    @State private var newItemQuantity = 0
    @State private var user: DBUser? = nil
    @State private var isLoading = true
    @State private var itemsfromDB:[Item] = []
    
    var body: some View {
        // @ObservedObject var arrayOfItems: [Item] = []
        // @ObservedObject var sharedItemsData = ItemsArraySharedData(/*itemList: []*/)
        if isLoading {
            VStack{
                Text("Loading...")
                Text("Retrieving Data From Database...")
            }
            .onAppear {
                Task {
                    // let user = try await profileViewModel.loadCurrentUser()
                    await loadCurrentUser()
                    // sharedItemsData.itemList = user.itemList
                    itemsfromDB = user!.itemList
                    isLoading = false
                }
            }
            
        } else {
            NavigationView {
                VStack {
                    List {
                        ForEach(self.user!.itemList) { item in
                            HStack {
                                Text("\(item.name)") .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                Text("Qty: \(item.quantity)") .frame(alignment: .trailing)
                                Spacer()
                            }
                        }
                        // .onDelete(perform: deleteItem)
                    }
                    .navigationTitle("Items List")
                    .id(UUID())
                    .toolbar {
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                isProfileSheetPresented.toggle()
                            }) {
                                Image(systemName: "person.crop.circle.fill")
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
//                                isProfileSheetPresented.toggle()
                                UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: WebAPIView())
                            }) {
                                Image(systemName: "web.camera.fill")
                            }
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                isAddItemSheetPresented.toggle()
                            }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
                .sheet(isPresented: $isAddItemSheetPresented) {
                    NavigationView {
                        Form {
                            Section(header: Text("New Item Details")) {
                                TextField("Item Name", text: $newItemName)
                                Stepper(value: $newItemQuantity, in: 0...100) {
                                    Text("Quantity: \(newItemQuantity)")
                                }
                            }
                            Button("Add Item") {
                                addItem()
                                isAddItemSheetPresented.toggle()
                            }
                            .foregroundColor(.red)
                        }
                        .navigationTitle("Add New Item")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Cancel") {
                                    isAddItemSheetPresented.toggle()
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
                .sheet(isPresented: $isProfileSheetPresented) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 100))
                    
                    ProfileView()
                }
            }
            .task{
                // user = try? await profileViewModel.loadCurrentUser()
                await loadCurrentUser()
            }
        }
            
    }
    
    func addItem() {
        Task{
            do {
                let newItem = Item(name: newItemName, quantity: newItemQuantity)
                try await viewModel.addItemList(userId: (user?.userId)!, newItem: newItem)
                
                self.user = try await profileViewModel.loadCurrentUser()
                itemsfromDB = user!.itemList
                
                newItemName = ""
                newItemQuantity = 0
                
            } catch {
                print(error)
            }
        }
    }
    
    func deleteItem(at offsets: IndexSet) {
        // tems.remove(atOffsets: offsets)
    }
    
    func loadCurrentUser() async {
        do {
            let authDataResult = AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.getUser(userId: authDataResult!.uid)
        } catch {
            print(error)
        }
    }
}
