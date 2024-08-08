import SwiftUI

struct InventoryStatusView: View {
    @StateObject private var profileViewModel = LoadCurrentUserModel()
    @StateObject private var viewModel = InventoryStatus_Handler()
    @State private var productList: [Product] = []
    @State private var categoryProductCounts: [CategoryProductCount] = []
    @State private var isAddItemSheetPresented = false
    @State private var isProfileSheetPresented = false
    @State private var user: DBUser? = nil
    @State private var isLoading = true
    @State private var selectedCategory: String? = nil
    @State private var selectedItem: String? = nil
    @State private var itemQuantity = ""
    @State private var categories: [String] = []
    
    var body: some View {
        if isLoading {
            VStack {
                Text("Loading...")
                Text("Retrieving Data From Database...")
            }
            .onAppear {
                Task {
                    self.user = try await profileViewModel.loadCurrentUser()
                    productList = user!.productList
                    categories = Array(Set(productList.map { $0.category }))
                    isLoading = false
                }
            }
        } else {
            NavigationView {
                VStack {
                    List {
                        ForEach(categoryProductCounts, id: \.category) { categoryProductCount in
                            ExpandableRow(title: categoryProductCount.category) {
                                ForEach(categoryProductCount.productCounts.keys.sorted(), id: \.self) { productName in
                                    HStack {
                                        Text(productName)
                                        Spacer()
                                        Text("Count: \(categoryProductCount.productCounts[productName] ?? "0")")
                                    }
                                }
                            }
                        }
                    }
                    .accentColor(.red)
                    .navigationTitle("Track Inventory")
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
                .sheet(isPresented: $isAddItemSheetPresented) {
                    NavigationView {
                        Form {
                            // Picker for Category with "None" as default
                            Picker("Select Category", selection: $selectedCategory) {
                                Text("None").tag(String?.none) // Explicitly set "None" tag to nil
                                ForEach(categories, id: \.self) { category in
                                    Text(category).tag(category as String?)
                                }
                            }
                            
                            // Conditionally show the Item Picker if a category is selected
                            if let selectedCategory = selectedCategory {
                                Picker("Select Item", selection: $selectedItem) {
                                    Text("None").tag(String?.none) // Explicitly set "None" tag to nil
                                    ForEach(productList.filter { $0.category == selectedCategory }.map { $0.name }, id: \.self) { productName in
                                        Text(productName).tag(productName as String?)
                                    }
                                }
                            }
                            
                            // Conditionally show the Stepper and Save button if an item is selected
                            if selectedItem != nil {
                                TextField("Quantity", text: $itemQuantity)
                                    .keyboardType(.decimalPad) // Ensure the keyboard shows number pad
                                
                                Button("Save") {
                                    if let selectedItem = selectedItem, let selectedCategory = selectedCategory {
                                        if let index = categoryProductCounts.firstIndex(where: { $0.category == selectedCategory }) {
                                            categoryProductCounts[index].productCounts[selectedItem] = itemQuantity
                                        } else {
                                            let newCategoryProductCount = CategoryProductCount(category: selectedCategory, productCounts: [selectedItem: itemQuantity])
                                            categoryProductCounts.append(newCategoryProductCount)
                                        }
                                    }
                                    isAddItemSheetPresented.toggle()
                                }
                                .foregroundColor(.red)
                            }
                        }
                        .navigationTitle("Add Item")
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
            .task {
                do {
                    self.user = try await profileViewModel.loadCurrentUser()
                    productList = user!.productList
                    categories = Array(Set(productList.map { $0.category }))
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
