//
//  ToastManager.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 03/12/1447 AH.
//

import SwiftUI

final class ToastManager: ObservableObject {
    @Published var isShowing = false
    @Published var message = ""

    func show(_ message: String, duration: Double = 3) {
        self.message = message

        withAnimation {
            isShowing = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation {
                self.isShowing = false
            }
        }
    }
}
