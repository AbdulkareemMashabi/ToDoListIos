//
//  ToDoListIosApp.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 22/04/1447 AH.
//

import SwiftUI
import Lottie

@main
struct ToDoListIosApp: App {
    @State var isLottieFinished = false
    @StateObject private var loadingManager = LoadingManager()
    @StateObject private var appToken = AppToken()
    @StateObject var navigationManager = NavigationManager()
    @StateObject var appColors = AppColors()
    let filePath = "/Users/abdulkareemmashabi/Desktop/ToDoListIos/ToDoListIos/Lotties/splash.json"
    var body: some Scene {
        WindowGroup {
            ZStack{
                NavigationStack(path: $navigationManager.path) {
                    VStack {
                        if (isLottieFinished)
                        {
                            Dashboard().transition(.opacity)
                        }
                        else {
                            LottieView(animation: .filepath(filePath)).playbackMode(.playing(.toProgress(1, loopMode: .playOnce))).animationDidFinish {
                                complete in
                                isLottieFinished = true
                            }.transition(.opacity).background(Color(white: 0.9))
                        }
                        
                    }.animation(.linear(duration: 0.3), value: isLottieFinished).navigationDestination(for: Route.self) { route in
                        switch route {
                        case .login:
                            Login()
                        case .register:
                            Register()
                        case .createNewTask:
                            CreateNewTask()
                        }
                    }
                }
                if loadingManager.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay(
                            ProgressView()
                                .scaleEffect(1.5).tint(.white)
                        )
                }
                if loadingManager.isLoadingButton {
                    Color.black.opacity(0.1)
                        .ignoresSafeArea()
                }
            }
            
            
            
            
        }.environmentObject(loadingManager).environmentObject(appToken).environmentObject(navigationManager).environmentObject(appColors)
        
    }
}
