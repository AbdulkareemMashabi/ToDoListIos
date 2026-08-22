//
//  Register.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 18/05/1447 AH.
//

import SwiftUI

struct Register: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @EnvironmentObject private var loadingManager: LoadingManager
    @EnvironmentObject private var appToken: AppToken
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var toastManager: ToastManager
    @EnvironmentObject private var alertManager: AlertManager

    private var isSubmitDisabled: Bool {
        email.isEmpty
        || password.isEmpty
        || confirmPassword.isEmpty
        || password != confirmPassword
        || password.count < 6
        || !Validators.isValidEmail(email)
    }

    var body: some View {
        ZStack {
            Image("waves").resizable().ignoresSafeArea()

            VStack(alignment: .leading) {
                TextInput(
                    data: $email,
                    placeholder: localized("common.email"),
                    error: Validators.email(email)
                )
                TextInput(
                    data: $password,
                    placeholder: localized("common.password"),
                    isSecureTextEntry: true,
                    error: Validators.password(password)
                )
                TextInput(
                    data: $confirmPassword,
                    placeholder: localized("common.confirmPassword"),
                    isSecureTextEntry: true,
                    error: Validators.confirmPassword(password, confirmPassword)
                )

                ButtonComponent(action: register) {
                    Text(localized("common.submit"))
                }
                .formButtonStyle()
                .isButtonDisabled(isSubmitDisabled)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
        }
        .customToolbar(title: localized("common.register"))
    }

    private func register() {
        Task { @MainActor in
            loadingManager.isLoadingButton = true
            defer { loadingManager.isLoadingButton = false }
            do {
                let token = try await signUpFireBase(email: email, password: password)
                Storage.save(key: AppConstants.tokenKeychainKey, value: token)
                appToken.token = token
                toastManager.show(localized("register.success"))
                navigationManager.path.removeAll()
            } catch {
                alertManager.show(message: error.userFacingMessage)
            }
        }
    }
}

#Preview {
    Register()
}
