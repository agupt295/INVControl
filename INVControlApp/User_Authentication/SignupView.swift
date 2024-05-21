import SwiftUI

enum ActiveAlert: Identifiable {
    case registrationSuccessful, emailEmpty, emailNotValid, passwordNotValid, confirmPasswordNotValid
    var id: Int {
        self.hashValue
    }
}

struct SignupView: View {
    
    @StateObject private var viewModel = SignInEmailViewModel()
    @State var userName: String=""
    @State var email: String=""
    @State var password: String=""
    @State var confirmPassword: String=""
    @State private var activeAlert: ActiveAlert?
    
    var body: some View {
        VStack (spacing: 20){
            
            TextField("Email", text: $email).padding()
            TextField("User Name", text: $userName).padding()
            TextField("Password", text: $password).padding()
            TextField("Confirm Password", text: $confirmPassword).padding()

            Spacer()
            
            ZStack{
                Rectangle()
                    .rotation(.degrees(-40))
                    .foregroundColor(.red)
                    .offset(x: -120, y: 160)
                    .frame(width: 1050, height: 250)
                
                VStack{
                    Button("Create Account") {
                        Task {
                            if(email == ""){ activeAlert = .emailEmpty }
                            else if(password.count < 6){ activeAlert = .passwordNotValid }
                            else if(password != confirmPassword) { activeAlert = .confirmPasswordNotValid }
                            else {
                                if(await viewModel.signIn(email: email, password: password, username: userName)){
                                    activeAlert = .registrationSuccessful;
                                } else {
                                    activeAlert = .emailNotValid
                                }
                            }
                        }
                    }
                    .padding()
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .background(Color.white)
                    .cornerRadius(5)
                    
                    NavigationLink(destination: Login()) {
                        Text("Already have an account? Log In")
                            .foregroundStyle(Color.white)
                    }
                    
                    .alert(item: $activeAlert) { alert in
                        switch alert {
                        case .registrationSuccessful:
                            return Alert(
                                title: Text("Account Registered!"),
                                dismissButton: .default(Text("OK")) {
                                    UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: HomePage())
                                }
                            )
                        case .emailEmpty:
                            return Alert(
                                title: Text("Incorrect Email"),
                                message: Text("Make sure to enter Email!"),
                                dismissButton: .default(Text("OK"))
                            )
                        case .emailNotValid:
                            return Alert(
                                title: Text("Incorrect Email Form"),
                                message: Text("Make sure to enter a correct Email format!"),
                                dismissButton: .default(Text("OK"))
                            )
                        case .passwordNotValid:
                            return Alert(
                                title: Text("Strong Password Required"),
                                message: Text("Length of password should be at least 6!"),
                                dismissButton: .default(Text("OK"))
                            )
                        case .confirmPasswordNotValid:
                            return Alert(
                                title: Text("Confirm Password Mismatch"),
                                message: Text("Make sure you input the correct password!"),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    SignupView()
}
