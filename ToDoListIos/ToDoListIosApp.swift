import SwiftUI
import Lottie
import FirebaseCore

@main
struct ToDoListIosApp: App {
    @State private var isLottieFinished = false

    @StateObject private var loadingManager = LoadingManager()
    @StateObject private var appToken = AppToken()
    @StateObject private var navigationManager = NavigationManager()
    @StateObject private var appColors = AppColors()
    @StateObject private var toastManager = ToastManager()
    @StateObject private var alertManager = AlertManager()
    @StateObject private var appLanguageManager = AppLanguageManager()
    // register app delegate for Firebase setup
      @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate


    let filePath = "/Users/abdulkareemmashabi/Desktop/ToDoListIos/ToDoListIos/Resources/Lotties/splash.json"

    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .top) {

                NavigationStack(path: $navigationManager.path) {

                    VStack {
                        if isLottieFinished {
                            Dashboard()
                                .transition(.opacity)

                        } else {
                            LottieView(animation: .filepath(filePath))
                                .playbackMode(
                                    .playing(
                                        .toProgress(
                                            1,
                                            loopMode: .playOnce
                                        )
                                    )
                                )
                                .animationDidFinish { _ in
                                    isLottieFinished = true
                                }
                                .transition(.opacity)
                                .background(Color(white: 0.9))
                        }
                    }
                    .animation(.linear(duration: 0.3), value: isLottieFinished)
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .login:
                            Login()

                        case .register:
                            Register()

                        case .createNewTask:
                            CreateNewTask()

                        case .forgetPassword:
                            ForgetPassword()
                            
                        case .accountDeletion:
                            AccountDeletion()
                        }
                    }
                }

                // MARK: - Full Screen Loader

                if loadingManager.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay(
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                        )
                        .zIndex(1000)
                }

                // MARK: - Button Loader Overlay

                if loadingManager.isLoadingButton {
                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                        .zIndex(999)
                }

                // MARK: - Toast

                if toastManager.isShowing {
                    ToastView(message: toastManager.message)
                        .padding(.top, 60)
                        .transition(
                            .move(edge: .top)
                                .combined(with: .opacity)
                        )
                        .zIndex(2000)
                }
            }
            .alert(alertManager.title, isPresented: $alertManager.isPresented) {
                Button(localized("common.ok")) {
                    alertManager.hide()
                }
            } message: {
                Text(alertManager.message)
            }
            .animation(.easeInOut(duration: 0.3), value: toastManager.isShowing)
            .environmentObject(loadingManager)
            .environmentObject(appToken)
            .environmentObject(navigationManager)
            .environmentObject(appColors)
            .environmentObject(toastManager)
            .environmentObject(alertManager)
            .environmentObject(appLanguageManager)
            .environment(\.locale, appLanguageManager.locale)
            .environment(\.layoutDirection, appLanguageManager.layoutDirection)
        }
    }
}
