import SwiftUI

struct AddItemView: View {
    @StateObject private var userManager = UserManager()
    @StateObject private var profileViewModel = LoadCurrentUserModel()
    @StateObject private var viewModel = AddItem_Handler()
    @State private var isAddItemSheetPresented = false
    @State private var isProfileSheetPresented = false
    @State private var newItemName = ""
    @State private var newItemQuantity = ""
    @State private var user: DBUser? = nil
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var selectedType: ItemType = .liquidOrPowder
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var filteredItems: [Item] {
        if searchText.isEmpty {
            return self.user?.itemList ?? []
        } else {
            return self.user?.itemList.filter { $0.name.lowercased().contains(searchText.lowercased()) } ?? []
        }
    }
    
    var body: some View {
        if isLoading {
            VStack{
                Text("Loading...")
                Text("Retrieving Data From Database...")
            }
            .onAppear {
                Task {
                    self.user = try await profileViewModel.loadCurrentUser()
                    isLoading = false
                }
            }
            
        } else {
            NavigationView {
                VStack {
                    List {
                        ForEach(filteredItems) { item in
                            HStack {
                                Text("\(item.name)")
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                Text("\(String(format: "%.2f", item.quantity)) \(item.type == .solids ? " units" : " mL/gm")")
                                    .frame(alignment: .trailing)
                                Spacer()
                            }
                        }
                    }
                    .navigationTitle("Track your sub-units")
                    .searchable(text: $searchText) // Add search bar
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
                            Section(header: Text("New Item Details")) {
                                
                                Picker("Type", selection: $selectedType) {
                                    Text("Liquid/Powder").tag(ItemType.liquidOrPowder)
                                    Text("Solids").tag(ItemType.solids)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                
                                TextField("Item Name", text: $newItemName)
                                
                                TextField("Quantity", text: $newItemQuantity)
                                    .keyboardType(selectedType == .liquidOrPowder ? .decimalPad : .numberPad)
                                
                                VStack {
                                    if selectedType == .liquidOrPowder {
                                        Text("Enter quantity in mL/gm!").frame(maxWidth: .infinity, alignment: .leading)
                                        Text("For example: if the quantity is 1L, enter 1000. (in mL)")
                                            .italic()
                                            .font(.footnote)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    } else {
                                        Text("Enter quantity in units!").frame(maxWidth: .infinity, alignment: .leading)
                                        Text("For example: if the quantity is 10, enter 10. (in units)")
                                            .italic()
                                            .font(.footnote)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            Button("Add sub-unit") {
                                if newItemName.isEmpty {
                                    alertMessage = "Item Name cannot be empty!"
                                    showAlert = true
                                } else if newItemQuantity.isEmpty {
                                    alertMessage = "Quantity cannot be empty!"
                                    showAlert = true
                                } else if let quantity = Double(newItemQuantity) {
                                    Task {
                                        do {
                                            self.user = try await viewModel.addItem(user: self.user!, newItemName: newItemName, newItemQuantity: quantity, itemType: selectedType)
                                            newItemName = ""
                                            newItemQuantity = ""
                                        } catch {
                                            print(error)
                                        }
                                    }
                                    isAddItemSheetPresented.toggle()
                                } else {
                                    alertMessage = "Invalid quantity entered."
                                    showAlert = true
                                }
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
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
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
                do {
                    self.user = try await profileViewModel.loadCurrentUser()
                } catch {
                    print(error)
                }
            }
        }
    }
}
