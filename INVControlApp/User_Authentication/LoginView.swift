import SwiftUI

struct LoginView: View {
    
    @StateObject private var viewModel = SignInEmailViewModel()
    @State var email: String=""
    @State var password: String=""
    @State var isLoginSuccessful: Bool = false
    
    var body: some View {
        VStack (spacing: 30) {
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            Spacer()
            
            ZStack{
                Rectangle()
                    .rotation(.degrees(-40))
                    .foregroundColor(.red)
                    .offset(x: -120, y: 160)
                    .frame(width: 1050, height: 250) // Set the width and height here
                
                VStack{
                    Button("Proceed") {
                        Task{
                            if (email != "") {
                                // it email is not in DB, then prompt "New User?"
                                // else check password
                                if(password != "") {
                                    // if password also matches then -> Go to the HomePage
                                    if (await viewModel.login(email: email, password: password)){
                                        isLoginSuccessful = true
                                    } else {
                                        // Login Unsuccessfull
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .background(Color.white)
                    .cornerRadius(5)
                    
                    NavigationLink(destination: Signup()) {
                        Text("Don't have an account? Sign Up").foregroundStyle(Color.white)
                    }
                    
                    .alert(isPresented: $isLoginSuccessful) {
                        Alert(
                            title: Text("Login Successful !"),
                            message: nil,
                            dismissButton: .default(Text("OK")) {
                                UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: HomePage())
                            }
                        )
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
