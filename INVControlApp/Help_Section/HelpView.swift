import SwiftUI

struct HelpView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Add Item")
                    .font(.title)
                    .foregroundColor(.red)
                Text("You can add new Items in your Inventory")
                    .multilineTextAlignment(.leading)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Add Order")
                    .font(.title)
                    .foregroundColor(.red)
                Text("You can add a new Product that can be made of multiple Items with varying Quantity")
                    .multilineTextAlignment(.leading)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("View Inventory")
                    .font(.title)
                    .foregroundColor(.red)
                Text("The Page will show you the quantity left in the Inventory with a Status Sign")
                    .multilineTextAlignment(.leading)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Orders")
                    .font(.title)
                    .foregroundColor(.red)
                Text("You can add make Products with varying quantity and after placing order, the Items will be deducted from your Inventory automatically")
                    .multilineTextAlignment(.leading)
            }
        }
        .padding() // Optional: add padding to the outer VStack
        Spacer()
    }
}

#Preview {
    HelpView()
}
