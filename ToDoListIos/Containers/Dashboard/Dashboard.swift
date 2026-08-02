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
    @EnvironmentObject private var loadingmanager: LoadingManager
    @EnvironmentObject private var alertManager: AlertManager
    @State private var tasks: [ToDoTask] = []
    
    var body: some View {
        VStack {
            if(appToken.token.isEmpty || tasks.isEmpty){
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
            }
            else {
                TaskListComponent(tasks: $tasks)

            }

        }.onAppear {
            Task {
                let newTasks = await loadTasksShared(appToken: appToken, loadingManager: loadingmanager, alertManager: alertManager)
                if !newTasks.isEmpty {
                    self.tasks = newTasks
                }
            }
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
                                        ]).padding(.horizontal).safeAreaInset(edge: .bottom) {
                                            if(!tasks.isEmpty)
                                            {
                                                NavigationLink(value: Route.createNewTask ) {
                                                    Text(localized("dashboard.addNewTask"))
                                                }.formButtonStyle().padding().background(.white).shadow(radius: 2).frame(maxWidth: .infinity)
                                            }

                                        }
    }
}

#Preview {
    Dashboard()
}
