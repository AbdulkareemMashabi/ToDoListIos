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
                Text(localized("accountDeletion.title")).fontWeight(.bold).font(.title)
                TextInput(data: $email, placeholder: localized("common.email"), error: getEmailValidation(email: email))
                TextInput(data: $password, placeholder: localized("common.password"), isSecureTextEntry: true, error: getEmptyErrorMessage(fieldName: localized("common.password"), fieldValue:password))
                ButtonComponent {
                    Task {
                        do {
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                            }
                            try await deleteAccountFirebase(email: email, password: password)
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                                toastManager.show(localized("accountDeletion.success"))
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
                    Text(localized("accountDeletion.button"))
                }.formButtonStyle().isButtonDisabled(isButtonDisabled)
            }.frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .top).padding()

        }
        

    }
}

#Preview {
    AccountDeletion()
}
