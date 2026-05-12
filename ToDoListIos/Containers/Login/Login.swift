//
//  Login.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 18/05/1447 AH.
//

import SwiftUI

struct Login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject private var loadingManager: LoadingManager
    @EnvironmentObject private var appToken: AppToken
    @EnvironmentObject private var navigationManager: NavigationManager
    private var isButtonDisabled: Bool {
        return email.isEmpty || password.isEmpty
    }
    var body: some View {
        ZStack{
            Image("waves").resizable().ignoresSafeArea()
            VStack(alignment:.leading) {
                
                
                Text("Don't miss your wishes").fontWeight(.bold)
                Text("Login here to save your wishes to the cloud").fontWeight(.bold).foregroundStyle(.gray)
                TextInput(data: $email, placeholder: "Email", error: getEmailValidation(email: email))
                TextInput(data: $password, placeholder: "Password", isSecureTextEntry: true, error: getEmptyErrorMessage(fieldName: "password", fieldValue:password))
                
                Button {

                } label: {
                    Text("Forget Password").fontWeight(.bold).foregroundColor(.cyan)
                }
                
                ButtonComponent {
                    Task {
                        do {
                           await MainActor.run {
                               loadingManager.isLoadingButton.toggle()
                            }
                            let token = try await login(email: email, password: password)
                            appToken.token = token ?? ""
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                                navigationManager.path.removeAll()
                             }
                            
                        } catch {
                            print("error \(error)")
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                            }
                        }
                    }
                } label: {
                    Text("Login")
                }.fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(.cyan)
                    .cornerRadius(16).disabled(isButtonDisabled).opacity(isButtonDisabled ? 0.5 : 1)
                
                NavigationLink(value: Route.register) {
                    Text("Register").fontWeight(.bold).foregroundColor(.cyan).frame(maxWidth:.infinity, alignment: .center).padding(.top)
                }
                
                Button {
                    
                } label: {
                    Image(systemName: "person").resizable().frame(width: 20, height: 20).foregroundColor(.cyan)
                    Text("Guest Login").foregroundColor(.cyan).fontWeight(.bold)
                }.frame(maxWidth:.infinity, alignment: .center).padding(.top)
                
                
                
            }       .frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .top).padding()
            
        }.customToolbar(title: "Login", rightButtons: [
            AnyView(
                Button {
                    
                } label: {
                    Image("accountDeletion")
                }
            )
        ])
        
        
    }
}

#Preview {
    Login()
}
