import SwiftUI
import Combine

class ItemsArraySharedData: ObservableObject {
    @Published var selectedTab = 0 // Keep track of the selected tab
}

struct HomePage: View {
    @ObservedObject public var SharedObject = ItemsArraySharedData()
    
    var body: some View {
        
        TabView(selection: $SharedObject.selectedTab) {
            
            AddItemView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Item")
                }
                .tag(0) // Tag to identify the view
            
            AddOrderView()
                .tabItem {
                    Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                    Text("Add Order")
                }
                .tag(1)
            
            InvStatus()
                .tabItem {
                    Image(systemName: "eye.circle.fill")
                    Text("View Inventory")
                }
                .tag(2)
            
            UpdateInvView()
                .tabItem {
                    Image(systemName: "fork.knife.circle.fill")
                    Text("Orders")
                }
                .tag(3)
            
            VStack{
                HelpView()
            }
            .tabItem {
                Image(systemName: "questionmark.circle.fill")
                Text("Help")
            }
            .tag(4)
        }
        .navigationBarBackButtonHidden(true)
        .accentColor(.red)
    }
}

#Preview {
    HomePage()
}
