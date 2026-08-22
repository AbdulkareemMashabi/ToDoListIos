//
//  StatusButton.swift
//  ToDoListIos
//
//  Circular status indicator used in task rows and task details. Shows a
//  checkmark image when completed, and a tappable colored circle otherwise.
//

import SwiftUI

struct StatusButton: View {
    let status: Bool
    let borderColor: Color
    let action: () -> Void

    var body: some View {
        if status {
            Image("check")
        } else {
            Button(action: action) {
                Circle()
                    .stroke(borderColor, lineWidth: 2)
                    .frame(width: 20, height: 20)
                    .contentShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }
}
