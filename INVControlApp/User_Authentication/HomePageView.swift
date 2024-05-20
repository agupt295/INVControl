import SwiftUI

struct HomePageView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image("Logo")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.red))
                    .shadow(color: Color(red: 192/255, green: 192/255, blue: 192/255), radius: 2)
                    .offset(y:-100)
                
                NavigationLink(destination: Login()) {
                    Text("Go to Login")
                        .frame(width: 200, height: 50)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                
                NavigationLink(destination: Signup()) {
                    Text("Go to SignUp")
                        .frame(width: 200, height: 50)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
            }
            .navigationTitle("INVControl")
        }
    }
}

struct Login: View {
    var body: some View {
        VStack {
            LoginView()
        }
        .navigationTitle("Login")
        .navigationBarBackButtonHidden(true)
    }
}

struct Signup: View {
    var body: some View {
        VStack {
            SignupView()
        }
        .navigationTitle("SignUp")
        .navigationBarBackButtonHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
