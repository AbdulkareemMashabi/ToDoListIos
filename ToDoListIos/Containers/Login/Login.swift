//
//  Login.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 18/05/1447 AH.
//

import SwiftUI
import UIKit

struct Login: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @EnvironmentObject private var loadingManager: LoadingManager
    @EnvironmentObject private var appToken: AppToken
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject var toastManager: ToastManager
    @EnvironmentObject var alertManager: AlertManager
    private var isButtonDisabled: Bool {
        return email.isEmpty || password.isEmpty ||  !isValidEmail(email)
    }
    var body: some View {
        ZStack{
            Image("waves").resizable().ignoresSafeArea()
            VStack(alignment:.leading) {
                
                
                Text(localized("login.title")).fontWeight(.bold)
                Text(localized("login.subtitle")).fontWeight(.bold).foregroundStyle(.gray)
                TextInput(data: $email, placeholder: localized("common.email"), error: getEmailValidation(email: email))
                TextInput(data: $password, placeholder: localized("common.password"), isSecureTextEntry: true, error: getEmptyErrorMessage(fieldName: localized("common.password"), fieldValue:password))
                
                Button {
                    navigationManager.path.append(Route.forgetPassword)
                } label: {
                    Text(localized("login.forgetPassword")).fontWeight(.bold).foregroundColor(.cyan)
                }
                
                ButtonComponent {
                    Task {
                        do {
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                            }
                            let token = try await loginFireBase(email: email, password: password)
                            Storage.save(key: "token", value: token)
                            appToken.token = token
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                                toastManager.show(localized("login.success"))
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
                    Text(localized("common.login"))
                }.formButtonStyle().isButtonDisabled(isButtonDisabled)
                
                NavigationLink(value: Route.register) {
                    Text(localized("common.register")).fontWeight(.bold).foregroundColor(.cyan).frame(maxWidth:.infinity, alignment: .center).padding(.top)
                }
                
                Button {
                    Task {
                        do {
                            await MainActor.run {
                                loadingManager.isLoading.toggle()
                            }
                            guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
                                throw AuthAPIError.missingDeviceID
                            }
                            Storage.save(key: "token", value: deviceId)
                            appToken.token = deviceId
                            await MainActor.run {
                                loadingManager.isLoading.toggle()
                                toastManager.show(localized("login.success"))
                                navigationManager.path.removeAll()
                            }
                        }catch {
                            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                            alertManager.show(message: message)
                            await MainActor.run {
                                loadingManager.isLoading.toggle()
                            }
                        }
                    }
                } label: {
                    Image(systemName: "person").resizable().frame(width: 20, height: 20).foregroundColor(.cyan)
                    Text(localized("login.guest")).foregroundColor(.cyan).fontWeight(.bold)
                }.frame(maxWidth:.infinity, alignment: .center).padding(.top)
                
                
                
            }       .frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .top).padding()
            
        }.customToolbar(title: localized("common.login"), rightButtons: [
            AnyView(
                Button {
                    navigationManager.path.append(.accountDeletion)
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
