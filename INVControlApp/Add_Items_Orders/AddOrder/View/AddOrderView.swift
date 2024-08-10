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
    @State private var category: String = ""
    @State private var selectedCategory: String = ""
    @State private var user: DBUser? = nil
    @State private var isLoading = true
    @State private var isLoadingTwo = true
    @State private var isAddingNewCategory = false
    
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
                        return Item(name: item.name, quantity: 0, type: item.type)
                    }
                    
                    isLoading = false
                }
            }
        } else {
            NavigationView {
                VStack {
                    List {
                        ForEach(Dictionary(grouping: productArray, by: { $0.category }).keys.sorted(), id: \.self) { category in
                            ExpandableRow(title: category) {
                                ForEach(productArray.filter { $0.category == category }, id: \.id) { product in
                                    ExpandableRow(title: product.name) {
                                        ForEach(product.requiredItemList.indices, id: \.self) { itemIndex in
                                            let item = product.requiredItemList[itemIndex]
//                                            Text("\(item.name): \(String(format: "%.2f", item.quantity)) mL/gm")
                                                Text("\(item.name): \(String(format: "%.2f", item.quantity)) \(item.type == .solids ? " units" : " mL/gm")")

                                        }
                                    }
                                }
                            }
                        }
                    }
                    .accentColor(.red)
                    .navigationTitle("View your products")
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
                                    return Item(name: item.name, quantity: 0, type: item.type)
                                }
                                
                                isLoadingTwo = false
                            }
                        }
                    } else {
                        NavigationView {
                            Form {
                                HStack {
                                    TextField("Order Name", text: $orderName)
                                }
                                Section(header: Text("Category")) {
                                    if isAddingNewCategory {
                                        TextField("New Category", text: $category)
                                        Button("Select Existing Category") {
                                            isAddingNewCategory.toggle()
                                        }
                                    } else {
                                        Picker("Select Category", selection: $selectedCategory) {
                                            Text("New Category").tag("New Category")
                                            ForEach(Array(Set(productArray.map { $0.category })), id: \.self) { category in
                                                Text(category).tag(category)
                                            }
                                        }
                                        .pickerStyle(MenuPickerStyle())
                                        Button("Add New Category") {
                                            isAddingNewCategory.toggle()
                                            selectedCategory = ""
                                        }
                                    }
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
                                Button("Add Product") {
                                    Task {
                                        do {
                                            let finalCategory = isAddingNewCategory ? category : selectedCategory
                                            self.user = try await viewModel.addProduct(user: self.user!, orderName: orderName, category: finalCategory, itemsArrayCopy: itemsArrayCopy)
                                            productArray = user!.productList
                                        } catch {
                                            print(error)
                                        }
                                    }
                                    isAddItemSheetPresented.toggle()
                                }
                                .foregroundColor(.red)
                                .navigationTitle("Add New Product")
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
                    }
                }
            }
            .task {
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
