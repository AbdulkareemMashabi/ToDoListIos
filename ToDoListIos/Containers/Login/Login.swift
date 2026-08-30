//
//  Login.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 18/05/1447 AH.
//

import SwiftUI
import UIKit

struct Login: View {
    @State private var email = ""
    @State private var password = ""

    @EnvironmentObject private var loadingManager: LoadingManager
    @EnvironmentObject private var appToken: AppToken
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var toastManager: ToastManager
    @EnvironmentObject private var alertManager: AlertManager
    @EnvironmentObject private var taskStore: TaskStore

    private var isSubmitDisabled: Bool {
        email.isEmpty || password.isEmpty || !Validators.isValidEmail(email)
    }

    var body: some View {
        ZStack {
            Image("waves").resizable().ignoresSafeArea()

            VStack(alignment: .leading) {
                Text(localized("login.title")).fontWeight(.bold)
                Text(localized("login.subtitle"))
                    .fontWeight(.bold)
                    .foregroundStyle(.gray)

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

                Button {
                    navigationManager.path.append(.forgetPassword)
                } label: {
                    Text(localized("login.forgetPassword"))
                        .fontWeight(.bold)
                        .foregroundColor(.cyan)
                }

                ButtonComponent(action: signIn) {
                    Text(localized("common.login"))
                }
                .formButtonStyle()
                .isButtonDisabled(isSubmitDisabled)

                Button {
                    navigationManager.path.append(.register)
                } label: {
                    Text(localized("common.register"))
                        .fontWeight(.bold)
                        .foregroundColor(.cyan)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)

                Button(action: signInAsGuest) {
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.cyan)
                    Text(localized("login.guest"))
                        .foregroundColor(.cyan)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding()
        }
        .customToolbar(title: localized("common.login"), rightButtons: [
            AnyView(
                Button {
                    navigationManager.path.append(.accountDeletion)
                } label: {
                    Image("accountDeletion")
                }
            )
        ])
    }

    private func signIn() {
        Task { @MainActor in
            loadingManager.isLoadingButton = true
            defer { loadingManager.isLoadingButton = false }
            do {
                let token = try await loginFireBase(email: email, password: password)
                Storage.save(key: AppConstants.tokenKeychainKey, value: token)
                appToken.token = token
                await refreshTaskStore(taskStore: taskStore, alertManager: alertManager)
                toastManager.show(localized("login.success"))
                navigationManager.path.removeAll()
            } catch {
                alertManager.show(message: error.userFacingMessage)
            }
        }
    }

    private func signInAsGuest() {
        Task { @MainActor in
            loadingManager.isLoading = true
            defer { loadingManager.isLoading = false }
            do {
                guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
                    throw APIError.missingDeviceID
                }
                Storage.save(key: AppConstants.tokenKeychainKey, value: deviceId)
                appToken.token = deviceId
                await refreshTaskStore(taskStore: taskStore, alertManager: alertManager)
                toastManager.show(localized("login.success"))
                navigationManager.path.removeAll()
            } catch {
                alertManager.show(message: error.userFacingMessage)
            }
        }
    }
}

#Preview {
    Login()
}
