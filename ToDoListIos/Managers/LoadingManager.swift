//
//  LoadingManager.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 09/10/1447 AH.
//

import Foundation

/// Global loading indicators. `isLoading` drives the full-screen spinner used
/// during background fetches; `isLoadingButton` drives the inline loader for
/// form submissions.
final class LoadingManager: ObservableObject {
    @Published var isLoading = false
    @Published var isLoadingButton = false
}
