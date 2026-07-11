//
//  Login.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 18/05/1447 AH.
//

import SwiftUI

struct Register: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @EnvironmentObject var loadingManager: LoadingManager
    @EnvironmentObject var appToken: AppToken
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var alertManager: AlertManager
    private var isButtonDisabled: Bool {
        return email.isEmpty || password.isEmpty || confirmPassword.isEmpty || (password != confirmPassword) || password.count < 6 || !isValidEmail(email)
    }
    var body: some View {
        ZStack{
            Image("waves").resizable().ignoresSafeArea()
            VStack(alignment:.leading) {
                
                TextInput(data: $email, placeholder: "Email", error: getEmailValidation(email: email))
                TextInput(data: $password, placeholder: "Password", isSecureTextEntry: true, error: getPasswordValidation(password: password))
                TextInput(data: $confirmPassword, placeholder: "Confirm Password", isSecureTextEntry: true, error: getConfirmPasswordValidation(password: password, confirmPassword: confirmPassword))
                
                ButtonComponent {
                    Task    {
                        do {
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                            }
                            let token = try await register(email: email, password: password)
                            appToken.token = token
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                                toastManager.show("Register successfully")
                                navigationManager.path.removeAll()
                            }
                        }
                        catch {
                            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                            alertManager.show(message: message)
                            print("error \(error)")
                            await MainActor.run {
                                loadingManager.isLoading.toggle()
                            }
                        }
                        
                    }
                } label: {
                    Text("Submit")
                }.fontWeight(.bold).foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(.cyan)
                    .cornerRadius(16).disabled(isButtonDisabled).opacity(isButtonDisabled ? 0.5 : 1)
                
                
            }       .frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .top).padding()
        }                .customToolbar(title: "Login", rightButtons: [
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
    Register()
}
