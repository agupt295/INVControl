import Foundation

@MainActor
final class Authentication_ViewModel: ObservableObject {
    func signIn(email: String, password: String, username: String) async -> Bool{
        do{
            let returedUserData = try await AuthenticationManager.shared.createuser(email: email, password: password)
            let userInfo = DBUser(userId: returedUserData.uid, email: email, username: username, password: password, itemList: [], productList: [], product_count_List: [])
            try await UserManager.shared.createNewUser(user: userInfo)
            return true
            
        } catch {
            print("Error: \(error)")
            return false
        }
    }
    
    func login(email: String, password: String) async -> Bool {
        do{
            _ = try await AuthenticationManager.shared.Login(email: email, password: password)
            return true
            
        } catch {
            print("{ERROR}: \(error)")
            return false
        }
    }
}
