//
//  ForgetPassword.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 30/11/1447 AH.
//

import SwiftUI

struct ForgetPassword: View {
    @State private var email = ""

    @EnvironmentObject private var loadingManager: LoadingManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var toastManager: ToastManager
    @EnvironmentObject private var alertManager: AlertManager

    private var isSubmitDisabled: Bool {
        email.isEmpty || !Validators.isValidEmail(email)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Image("waves").resizable().ignoresSafeArea()

            VStack(alignment: .leading) {
                Text(localized("forgetPassword.title")).fontWeight(.bold)
                Text(localized("forgetPassword.subtitle")).foregroundStyle(.gray)

                TextInput(
                    data: $email,
                    placeholder: localized("common.email"),
                    error: Validators.email(email)
                )

                ButtonComponent(action: sendReset) {
                    Text(localized("common.submit"))
                }
                .formButtonStyle()
                .isButtonDisabled(isSubmitDisabled)
            }
            .padding()
        }
        .navigationTitle(localized("login.forgetPassword"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sendReset() {
        Task { @MainActor in
            loadingManager.isLoadingButton = true
            defer { loadingManager.isLoadingButton = false }
            do {
                try await resetPasswordFirebase(email: email)
                toastManager.show(localized("forgetPassword.resetSent"))
                navigationManager.path.removeLast()
            } catch {
                alertManager.show(message: error.userFacingMessage)
            }
        }
    }
}

#Preview {
    ForgetPassword()
}
