//
//  ToastManager.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 03/12/1447 AH.
//

import SwiftUI

@MainActor
final class ToastManager: ObservableObject {
    @Published private(set) var isShowing = false
    @Published private(set) var message = ""

    func show(_ message: String, duration: Double = 3) {
        self.message = message

        withAnimation { isShowing = true }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard let self else { return }
            withAnimation { self.isShowing = false }
        }
    }
}
