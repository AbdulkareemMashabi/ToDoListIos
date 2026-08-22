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
    @EnvironmentObject private var loadingManager: LoadingManager
    @EnvironmentObject private var alertManager: AlertManager
    @EnvironmentObject private var taskStore: TaskStore

    private var isEmpty: Bool {
        appToken.token.isEmpty || taskStore.tasks.isEmpty
    }

    var body: some View {
        VStack {
            if isEmpty {
                emptyState
            } else {
                TaskListComponent(tasks: $taskStore.tasks)
            }
        }
        .onAppear(perform: loadTasks)
        .customToolbar(
            title: localized("app.title"),
            leftButtons: [],
            rightButtons: [
                AnyView(languageToggleButton),
                AnyView(sessionButton)
            ]
        )
        .padding(.horizontal)
        .safeAreaInset(edge: .bottom) {
            if !taskStore.tasks.isEmpty && !appToken.token.isEmpty {
                addTaskButton
            }
        }
    }

    // MARK: - Subviews

    private var emptyState: some View {
        VStack {
            Image("emptyListPic").imageScale(.large)
            Text(localized("dashboard.emptyTitle")).fontWeight(.bold)
            Text(localized("dashboard.emptySubtitle"))
                .fontWeight(.bold)
                .foregroundStyle(.gray)

            Button {
                navigationManager.path.append(appToken.token.isEmpty ? .login : .createNewTask)
            } label: {
                Image(systemName: "plus")
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 40)
        }
    }

    private var languageToggleButton: some View {
        Button {
            if AppLanguageManager.selectedLanguage.rawValue == "ar" {
                appLanguageManager.useEnglish()
            } else {
                appLanguageManager.useArabic()
            }
        } label: {
            Image(systemName: "globe").foregroundStyle(.blue)
        }
    }

    private var sessionButton: some View {
        Button {
            if appToken.token.isEmpty {
                navigationManager.path.append(.login)
            } else {
                appToken.token = ""
                Storage.save(key: AppConstants.tokenKeychainKey, value: "")
            }
        } label: {
            if appToken.token.isEmpty {
                Image(systemName: "cloud").foregroundStyle(.blue)
            } else {
                Image("logOut")
            }
        }
    }

    private var addTaskButton: some View {
        Button {
            navigationManager.path.append(.createNewTask)
        } label: {
            Text(localized("dashboard.addNewTask"))
        }
        .formButtonStyle()
        .padding()
        .background(.white)
        .shadow(radius: 2)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Actions

    private func loadTasks() {
        Task { @MainActor in
            let newTasks = await loadTasksShared(
                appToken: appToken,
                loadingManager: loadingManager,
                alertManager: alertManager
            )
            if !newTasks.isEmpty {
                taskStore.tasks = newTasks
            }
        }
    }
}

#Preview {
    Dashboard()
}
