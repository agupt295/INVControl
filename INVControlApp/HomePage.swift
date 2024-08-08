import SwiftUI
import Combine

class ItemsArraySharedData: ObservableObject {
    @Published var selectedTab = 0
}

struct HomePage: View {
    @ObservedObject public var SharedObject = ItemsArraySharedData()
    
    var body: some View {
        
        TabView(selection: $SharedObject.selectedTab) {
            
            AddItemView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Sub-units")
                }
                .tag(0) // Tag to identify the view
            
            AddOrderView()
                .tabItem {
                    Image(systemName: "filemenu.and.selection")
                    Text("Products")
                }
                .tag(1)
            
            InventoryStatusView()
                .tabItem {
                    Image(systemName: "cube.box.fill")
                    Text("Inventory")
                }
                .tag(2)
            
            UpdateInvView()
                .tabItem {
                    Image(systemName: "minus.diamond.fillperson.crop.circle")
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
