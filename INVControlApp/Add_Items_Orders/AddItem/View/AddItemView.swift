import SwiftUI

struct AddItemView: View {
    @StateObject private var userManager = UserManager()
    @StateObject private var profileViewModel = LoadCurrentUserModel()
    @StateObject private var viewModel = AddItem_Handler()
    @State private var isAddItemSheetPresented = false
    @State private var isProfileSheetPresented = false
    @State private var newItemName = ""
    @State private var newItemQuantity = 0
    @State private var user: DBUser? = nil
    @State private var isLoading = true
    
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
                        ForEach(self.user!.itemList) { item in
                            HStack {
                                Text("\(item.name)") .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                Text("Qty: \(item.quantity)") .frame(alignment: .trailing)
                                Spacer()
                            }
                        }
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
                                Task {
                                    do {
                                        self.user = try await viewModel.addItem(user: self.user!, newItemName: newItemName, newItemQuantity: newItemQuantity)
                                        newItemName = ""
                                        newItemQuantity = 0
                                    } catch {
                                        print(error)
                                    }
                                }
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
                do {
                    self.user = try await profileViewModel.loadCurrentUser()
                } catch {
                    print(error)
                }
            }
        }
    }
}
