import SwiftUI

struct AddOrderView: View {
    @StateObject private var userManager = UserManager()
    @StateObject private var profileViewModel = LoadCurrentUserModel()
    @StateObject private var viewModel = AddOrder_Handler()
    @State private var productArray: [Product] = []
    @State private var itemsArrayCopy: [Item] = []
    @State private var isAddItemSheetPresented = false
    @State private var isProfileSheetPresented = false
    @State private var orderName: String = ""
    @State private var user: DBUser? = nil
    @State private var isLoading = true
    @State private var isLoadingTwo = true
    
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
                    
                    itemsArrayCopy = user!.itemList.map { item in
                        return Item(name: item.name, quantity: 0)
                    }
                    
                    isLoading = false
                }
            }
            
        } else {
            NavigationView {
                VStack {
                    List {
                        ForEach(productArray.indices, id: \.self) { productIndex in
                            ExpandableRow(title: productArray[productIndex].name) {
                                ForEach(productArray[productIndex].requiredItemList.indices, id: \.self) { itemIndex in
                                    let item = productArray[productIndex].requiredItemList[itemIndex]
                                    Text("\(item.name): \(item.quantity)")
                                }
                            }
                        }
                    }
                    .accentColor(.red)
                    
                    .navigationTitle("Orders List")
                    .toolbar {
                        
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                isProfileSheetPresented.toggle()
                            }) {
                                Image(systemName: "person.crop.circle.fill")
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
                .accentColor(.red)
                
                .sheet(isPresented: $isAddItemSheetPresented) {
                    if isLoadingTwo {
                        VStack {
                            Text("Loading...")
                            Text("Retrieving Data From Database...")
                        }
                        .onAppear {
                            Task {
                                self.user = try await profileViewModel.loadCurrentUser()
                                
                                itemsArrayCopy = user!.itemList.map { item in
                                    return Item(name: item.name, quantity: 0)
                                }
                                
                                isLoadingTwo = false
                            }
                        }
                    } else {
                        NavigationView {
                            Form {
                                HStack{
                                    TextField("Order Name", text: $orderName)
                                }
                                
                                Section(header: Text("Item Details")) {
                                    ForEach(itemsArrayCopy.indices, id: \.self) { itemIndex in
                                        HStack {
                                            Text("\(itemsArrayCopy[itemIndex].name)")
                                            Stepper(value: $itemsArrayCopy[itemIndex].quantity, in: 0...100) {
                                                Text("Qty: \(itemsArrayCopy[itemIndex].quantity)")
                                            }
                                        }
                                    }
                                }
                                
                                Button("Add Order") {
                                    Task {
                                        do {
                                            self.user = try await viewModel.addProduct(user: self.user!, orderName: orderName, itemsArrayCopy: itemsArrayCopy)
                                            productArray = user!.productList
                                            
                                        } catch {
                                            print(error)
                                        }
                                    }
                                    isAddItemSheetPresented.toggle()
                                }
                                .foregroundColor(.red)
                                
                                .navigationTitle("Add New Order")
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
                }
            }
            .task{
                do {
                    self.user = try await profileViewModel.loadCurrentUser()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    struct ExpandableRow<Content: View>: View {
        var title: String
        @State private var isExpanded: Bool = false
        var content: () -> Content
        
        var body: some View {
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    content()
                },
                label: {
                    Text(title)
                }
            )
            .accentColor(Color(.red))
        }
    }
}
