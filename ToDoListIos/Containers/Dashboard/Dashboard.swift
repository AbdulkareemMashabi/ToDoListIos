//
//  Dashboard.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 07/05/1447 AH.
//

import SwiftUI

struct Dashboard: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var appToken: AppToken
    @EnvironmentObject private var appLanguageManager: AppLanguageManager
    
    var body: some View {
        VStack {
            Image("emptyListPic")
                .imageScale(.large)
            Text(localized("dashboard.emptyTitle")).fontWeight(.bold)
            Text(localized("dashboard.emptySubtitle")).fontWeight(.bold).foregroundStyle(.gray)
            NavigationLink(value: appToken.token.isEmpty ? Route.login : Route.createNewTask ) {
                Image(systemName: "plus")
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 40)
        }.onAppear {
            appToken.token = Storage.load(key: "token") ?? ""
        }.customToolbar(                title: localized("app.title"),
                                        leftButtons: [],
                                        rightButtons: [
                                            AnyView(Button {
                                                AppLanguageManager.selectedLanguage.rawValue == "ar" ? appLanguageManager.useEnglish() : appLanguageManager.useArabic()
                                                
                                            } label: {
                                                Image(systemName: "globe").foregroundStyle(.blue)
                                            }),
                                            AnyView(Button {
                                                if(appToken.token.isEmpty)
                                                {
                                                    navigationManager.path.append(.login)
                                                }
                                                else {
                                                    appToken.token = ""
                                                    Storage.save(key: "token", value: "")
                                                }
                                            } label: {
                                                if(appToken.token.isEmpty) {
                                                    Image(systemName:"cloud").foregroundStyle(.blue)
                                                }
                                                else {
                                                    Image("logOut")
                                                }
                                            })
                                        ]).padding()
    }
}

#Preview {
    Dashboard()
}
