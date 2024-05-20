import SwiftUI

struct SignupView: View {
    
    @StateObject private var viewModel = SignInEmailViewModel()
    
    @State var userName: String=""
    @State var email: String=""
    @State var password: String=""
    @State var confirmPassword: String=""
    @State var isRegistrationSuccessful: Bool = false
//    @State var warehouseLoc: String = ""
//    @State private var selectedState = "Warehouse Location"
    
    var body: some View {
        VStack (spacing: 20){
            
            TextField("Email", text: $email) .padding()
            TextField("User Name", text: $userName) .padding()

//             HStack {
//                Text("WareHouse Location")
//                
//                Picker(selection: $selectedState, label: Text("")) {
//                    ForEach(states, id: \.self) { state in
//                        Text(state).tag(state)
//                    }
//                }
//                .pickerStyle(.menu)
//                .onChange(of: selectedState) { newValue in
//                    warehouseLoc = newValue
//                }
//            }
            .padding()

            TextField("Password", text: $password) .padding()
            TextField("Confirm Password", text: $confirmPassword) .padding()

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
                            if(email != "" && password == confirmPassword){
                                if(await viewModel.signIn(email: email, password: password, username: userName/*, warehouseLocation: selectedState*/)){
                                    // successful Login
                                    isRegistrationSuccessful = true
                                } else {
                                    // TO-DO: Password length < 6 or Email does not exist in the Database
                                    // Un-successful Login
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
                    
                    .alert(isPresented: $isRegistrationSuccessful) {
                        Alert(
                            title: Text("Account Registered !"),
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
    SignupView()
}
