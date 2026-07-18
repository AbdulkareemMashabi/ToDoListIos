//
//  AccountDeletion.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 03/02/1448 AH.
//

import SwiftUI

struct AccountDeletion: View {
    @State var email: String = ""
    @State var password: String = ""
    private var isButtonDisabled: Bool {
        return email.isEmpty || password.isEmpty || !isValidEmail(email)
    }
    @EnvironmentObject private var loadingManager: LoadingManager
    @EnvironmentObject private var appToken: AppToken
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var alertManager: AlertManager
    var body: some View {
        ZStack{
            Image("waves").resizable().ignoresSafeArea()
            VStack(alignment:.leading) {
                Text("Enter your Email and Password to Delete your Account").fontWeight(.bold).font(.title)
                TextInput(data: $email, placeholder: "Email", error: getEmailValidation(email: email))
                TextInput(data: $password, placeholder: "Password", isSecureTextEntry: true, error: getEmptyErrorMessage(fieldName: "password", fieldValue:password))
                ButtonComponent {
                    Task {
                        do {
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                            }
                            try await deleteAccountFirebase(email: email, password: password)
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                                toastManager.show("App Deleted successfully")
                                navigationManager.path.removeAll()
                            }
                            
                        } catch {
                            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                            alertManager.show(message: message)
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                            }
                        }
                    }
                    
                } label: {
                    Text("Delete Account")
                }.formButtonStyle().isButtonDisabled(isButtonDisabled)
            }.frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .top).padding()

        }
        

    }
}

#Preview {
    AccountDeletion()
}
