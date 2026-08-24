//
//  AlertManager.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 25/01/1448 AH.
//

import SwiftUI

enum ButtonsVariant {
    case danger
    case normal

    var color: Color {
        switch self {
        case .danger: return .red
        case .normal: return .cyan
        }
    }
}

class AlertButton: Identifiable {
    let id = UUID()
    let title: String
    let action: () -> Void
    let buttonVariant: ButtonsVariant

    init(title: String, action: @escaping () -> Void, buttonVariant: ButtonsVariant) {
        self.title = title
        self.action = action
        self.buttonVariant = buttonVariant
    }
}

@MainActor
final class AlertManager: ObservableObject {
    @Published var isPresented = false
    @Published var title = ""
    @Published var message = ""
    @Published var buttons: [AlertButton] = []

    func show(
        title: String = localized("common.error"),
        message: String,
        buttons: [AlertButton] = []
    ) {
        self.title = title
        self.message = message
        self.buttons = buttons
        isPresented = true
    }

    func hide() {
        isPresented = false
    }
}
