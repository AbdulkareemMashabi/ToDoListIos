//
//  ForgetPassword.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 30/11/1447 AH.
//

import SwiftUI

struct ForgetPassword: View {
    @State private var email = ""
    private var isButtonDisabled: Bool {
        return !isValidEmail(email) || email.isEmpty
    }
    @EnvironmentObject private var loadingManager: LoadingManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var alertManager: AlertManager
    
    var body: some View {
        ZStack (alignment: .top){
            Image("waves").resizable().ignoresSafeArea()
            VStack(alignment:.leading) {
                Text("Please enter email").fontWeight(.bold)
                Text("You will recieve an email with reset link").foregroundStyle(.gray)
                TextInput(data: $email, placeholder: "Email", error: getEmailValidation(email: email))
                ButtonComponent {
                    Task {
                        do {
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                            }
                            try await resetPasswordFirebase(email: email)
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                                toastManager.show("Password reset email sent")
                                navigationManager.path.removeLast()
                            }
                        }catch {
                            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                            alertManager.show(message: message)
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                            }
                        }
                    }
                    
                } label: {
                    Text("Submit")
                }.formButtonStyle().isButtonDisabled(isButtonDisabled)
                
            }.padding()
            
            
        }.navigationTitle("Forget Password").navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ForgetPassword()
}
