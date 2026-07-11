//
//  AlertManager.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 25/01/1448 AH.
//

import SwiftUI

@MainActor
final class AlertManager: ObservableObject {
    @Published var isPresented = false
    @Published var title = ""
    @Published var message = ""

    func show(title: String = "Error", message: String) {
        self.title = title
        self.message = message
        self.isPresented = true
    }

    func hide() {
        isPresented = false
    }
}
