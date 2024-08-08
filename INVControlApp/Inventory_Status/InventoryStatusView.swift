import SwiftUI

struct InventoryStatusView: View {
    @StateObject private var profileViewModel = LoadCurrentUserModel()
    @StateObject private var viewModel = InventoryStatus_Handler()
    
    @State private var product_count_Array: [Product_with_Item_Count] = []
    @State private var productList: [Product] = []
    @State private var categoryProductCounts: [CategoryProductCount] = []
    @State private var isAddItemSheetPresented = false
    @State private var isProfileSheetPresented = false
    @State private var user: DBUser? = nil
    @State private var isLoading = true
    
    @State private var selectedCategory: String? = nil
    @State private var selectedItem: Item_Count? = nil
    @State private var itemQuantity: Int = 0
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
                    product_count_Array = user!.product_count_List
                    productList = user!.productList
                    categories = Array(Set(productList.map { $0.category }))
                    categoryProductCounts = getCategoryProductCounts(products: product_count_Array)
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
                                        Text("Count: \(categoryProductCount.productCounts[productName] ?? 0)")
                                    }
                                }
                            }
                        }
                    }
                    .accentColor(.red)
                    .navigationTitle("Inventory Status")
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
                            Picker("Select Category", selection: $selectedCategory) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category).tag(category as String?)
                                }
                            }
                            
                            if let selectedCategory = selectedCategory {
                                Picker("Select Item", selection: $selectedItem) {
                                    ForEach(productList.filter { $0.category == selectedCategory }.flatMap { $0.requiredItemList }, id: \.id) { item in
                                        Text(item.name)
                                    }
                                }
                                
                                if let _ = selectedItem {
                                    Stepper(value: $itemQuantity, in: 0...100) {
                                        Text("Quantity: \(itemQuantity)")
                                    }
                                }
                            }
                            
                            Button("Save") {
                                if let selectedItem = selectedItem {
                                    // Update the count in the categoryProductCounts array
                                    if let index = categoryProductCounts.firstIndex(where: { $0.category == selectedCategory }) {
                                        categoryProductCounts[index].productCounts[selectedItem.name] = itemQuantity
                                    } else {
                                        let newCategoryProductCount = CategoryProductCount(category: selectedCategory!, productCounts: [selectedItem.name: itemQuantity])
                                        categoryProductCounts.append(newCategoryProductCount)
                                    }
                                }
                                isAddItemSheetPresented.toggle()
                            }
                            .foregroundColor(.red)
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
