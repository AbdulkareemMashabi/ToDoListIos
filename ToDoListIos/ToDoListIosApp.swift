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
            NavigationStack(path: $navigationManager.path) {
                RootContentView()
                    .navigationDestination(for: Route.self, destination: destination(for:))
            }
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
}
