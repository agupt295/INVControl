import SwiftUI

struct ProfileView: View {
    
    @State private var showAlert = false
    @StateObject private var viewModel = LoadCurrentUserModel()
    
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
            
            Section(header: Text(" ").foregroundColor(.red)){
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
                            UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: HomePageView())
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
