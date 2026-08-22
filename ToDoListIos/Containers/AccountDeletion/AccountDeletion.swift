//
//  AccountDeletion.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 03/02/1448 AH.
//

import SwiftUI

struct AccountDeletion: View {
    @State private var email = ""
    @State private var password = ""

    @EnvironmentObject private var loadingManager: LoadingManager
    @EnvironmentObject private var appToken: AppToken
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var toastManager: ToastManager
    @EnvironmentObject private var alertManager: AlertManager

    private var isSubmitDisabled: Bool {
        email.isEmpty || password.isEmpty || !Validators.isValidEmail(email)
    }

    var body: some View {
        ZStack {
            Image("waves").resizable().ignoresSafeArea()

            VStack(alignment: .leading) {
                Text(localized("accountDeletion.title"))
                    .fontWeight(.bold)
                    .font(.title)

                TextInput(
                    data: $email,
                    placeholder: localized("common.email"),
                    error: Validators.email(email)
                )
                TextInput(
                    data: $password,
                    placeholder: localized("common.password"),
                    isSecureTextEntry: true,
                    error: Validators.required(fieldName: localized("common.password"), value: password)
                )

                ButtonComponent(action: deleteAccount) {
                    Text(localized("accountDeletion.button"))
                }
                .formButtonStyle()
                .isButtonDisabled(isSubmitDisabled)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
        }
    }

    private func deleteAccount() {
        Task { @MainActor in
            loadingManager.isLoadingButton = true
            defer { loadingManager.isLoadingButton = false }
            do {
                try await deleteAccountFirebase(email: email, password: password)
                toastManager.show(localized("accountDeletion.success"))
                navigationManager.path.removeAll()
            } catch {
                alertManager.show(message: error.userFacingMessage)
            }
        }
    }
}

#Preview {
    AccountDeletion()
}
