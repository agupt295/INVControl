import SwiftUI

struct InventoryStatusView: View {
    @StateObject private var profileViewModel = LoadCurrentUserModel()
    @State private var isProfileSheetPresented = false
    @State private var user: DBUser? = nil
    @State private var isLoading = true
    @State private var itemsfromDB:[Item] = []
    
    var body: some View {
        if isLoading {
            VStack{
                Text("Getting Data from Database")
            }
            .onAppear {
                Task{
                    await loadCurrentUser()
                    itemsfromDB = user!.itemList
                }
                isLoading = false
            }
        } else {
            NavigationView {
                List(itemsfromDB) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text("Quantity: \(item.quantity)")
                        Text(item.status)
                            .font(.headline)
                    }
                }
                .navigationTitle("Inventory Status")
                .toolbar {
                    
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            isProfileSheetPresented.toggle()
                        }) {
                            Image(systemName: "person.crop.circle.fill")
                        }
                    }
                }
            }
            .sheet(isPresented: $isProfileSheetPresented) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 100))
                
                ProfileView()
            }
            .task{
                // user = try? await profileViewModel.loadCurrentUser()
                await loadCurrentUser()
                itemsfromDB = user!.itemList
            }
        }
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
