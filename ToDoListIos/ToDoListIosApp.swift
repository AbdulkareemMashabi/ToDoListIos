import SwiftUI

@main
struct ToDoListIosApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    @StateObject private var loadingManager = LoadingManager()
    @StateObject private var appToken = AppToken()
    @StateObject private var navigationManager = NavigationManager()
    @StateObject private var appColors = AppColors()
    @StateObject private var toastManager = ToastManager()
    @StateObject private var alertManager = AlertManager()
    @StateObject private var appLanguageManager = AppLanguageManager()
    @StateObject private var lottieManager = LottieManager()
    @StateObject private var taskStore = TaskStore()

    var body: some Scene {
        WindowGroup {
            AppRoot()
                .dismissKeyboardOnTap()
                .appOverlays()
                .environmentObject(loadingManager)
                .environmentObject(appToken)
                .environmentObject(navigationManager)
                .environmentObject(appColors)
                .environmentObject(toastManager)
                .environmentObject(alertManager)
                .environmentObject(appLanguageManager)
                .environmentObject(lottieManager)
                .environmentObject(taskStore)
                .environment(\.locale, appLanguageManager.locale)
                .environment(\.layoutDirection, appLanguageManager.layoutDirection)
                .id(appLanguageManager.language)
                .onOpenURL { url in
                    processWidgetAction(url: url, taskStore: taskStore, lottieManager: lottieManager)
                }
        }
    }
}

/// Root layout that picks between `NavigationSplitView` (regular width, e.g.
/// iPad or unfolded iPhone Duo) and a plain `NavigationStack` (compact
/// width, e.g. iPhone or Slide Over). On regular, Dashboard stays visible
/// in the detail column while TaskDetails renders in the toggleable sidebar
/// column. On compact, TaskDetails is pushed onto the stack so the system
/// back button behaves normally.
private struct AppRoot: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    @EnvironmentObject private var navigationManager: NavigationManager

    var body: some View {
        if sizeClass == .regular {
            NavigationSplitView(columnVisibility: $navigationManager.columnVisibility) {
                NavigationStack {
                    taskDetailsColumn
                }
            } detail: {
                NavigationStack(path: $navigationManager.path) {
                    RootContentView()
                        .navigationDestination(for: Route.self, destination: destination(for:))
                }
            }
        } else {
            NavigationStack(path: $navigationManager.path) {
                RootContentView()
                    .navigationDestination(for: Route.self, destination: destination(for:))
            }
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .login:            Login()
        case .register:         Register()
        case .createNewTask:    CreateNewTask()
        case .forgetPassword:   ForgetPassword()
        case .accountDeletion:  AccountDeletion()
        case .taskDetails(let task): TaskDetails(task: task)
        }
    }

    @ViewBuilder
    private var taskDetailsColumn: some View {
        if let task = navigationManager.selectedTask {
            TaskDetails(task: task)
                .id(task.documentID ?? task.mainTask.title)
        } else {
            ContentUnavailableView(
                localized("taskDetails.placeholderTitle"),
                systemImage: "checklist",
                description: Text(localized("taskDetails.placeholderSubtitle"))
            )
        }
    }
}
