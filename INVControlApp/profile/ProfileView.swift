import SwiftUI
import MapKit

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published private(set) var user: DBUser? = nil    
    
    func loadCurrentUser() async throws -> DBUser {
        do {
            let authDataResult = AuthenticationManager.shared.getAuthenticatedUser()
            self.user = try await UserManager.shared.getUser(userId: authDataResult!.uid)
            return self.user!
        } catch {
            print(error)
        }
        return self.user!
    }
}

struct ProfileView: View {
    
    @State private var showAlert = false
    @State var location: String = "India"
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        Form {
            Section(header: Text("Account Information").foregroundColor(.red)){
                if let user = viewModel.user {
                    if let userName = user.username {
                        Text("User Name: \(userName)")
                    }
                    
                    if let user_password = user.password {
                        Text("Password: \(user_password)")
                    }
                }
            }
            
            Section(header: Text("Contact Details").foregroundColor(.red)){
                
                if let user = viewModel.user {
                    if let userEmail = user.email {
                        Text("Email: \(userEmail)")
                    }
                }
            }
            
            Section(header: Text("Warehouse Location").foregroundColor(.red)){
                
                if let user = viewModel.user {
                    if let location = user.warehouseLocation {
                        MapView(wareHouseLocation: location) .frame(width: 300, height: 300)
                    }
                }
                
                Button("Logout") {
                    Task {
                        do {
                            showAlert = true
                        }
                    }
                }
                .foregroundColor(Color.red)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Logout?"),
                message: Text("Are you sure you want to Logout?"),
                primaryButton: .default(Text("Continue").foregroundStyle(Color(.red))) {
                    
                    Task {
                        do {
                            try await AuthenticationManager.shared.logOut()
                            UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: UserDataEntry())
                        } catch {
                            print(error)
                        }
                    }
                },
                secondaryButton: .cancel(
                    Text("Cancel").foregroundStyle(Color(.red))
                )
            )
        }
        .task{
            _ = try? await viewModel.loadCurrentUser()
        }
    }
}
