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
                Text(localized("forgetPassword.title")).fontWeight(.bold)
                Text(localized("forgetPassword.subtitle")).foregroundStyle(.gray)
                TextInput(data: $email, placeholder: localized("common.email"), error: getEmailValidation(email: email))
                ButtonComponent {
                    Task {
                        do {
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                            }
                            try await resetPasswordFirebase(email: email)
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                                toastManager.show(localized("forgetPassword.resetSent"))
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
                    Text(localized("common.submit"))
                }.formButtonStyle().isButtonDisabled(isButtonDisabled)
                
            }.padding()
            
            
        }.navigationTitle(localized("login.forgetPassword")).navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ForgetPassword()
}
