//
//  TaskSwipeActionsModifier.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 25/02/1448 AH.
//

import SwiftUI

/// Adds the info / delete / favorite swipe actions to a task row, and plays a
/// small "swipe hint" animation the first time the list contains a single task.
struct TaskSwipeActionsModifier: ViewModifier {
    @Binding var task: ToDoTask
    let showSwipeHint: Bool
    let deleteTask: (String) -> Void
    let makeTaskUnfavorite: (String) -> Void

    @EnvironmentObject private var alertManager: AlertManager
    @EnvironmentObject private var navigationManager: NavigationManager

    @State private var hintOffset: CGFloat = 0

    private static let hintSpring: Animation = .interpolatingSpring(stiffness: 300, damping: 15)

    func body(content: Content) -> some View {
        content
            .offset(x: hintOffset)
            .onAppear(perform: playSwipeHintIfNeeded)
            .swipeActions {
                infoAction
                deleteAction
                favoriteAction
            }
    }

    // MARK: - Actions

    private var infoAction: some View {
        Button {
            navigationManager.path.append(.taskDetails(task))
        } label: {
            Image("info")
        }
        .tint(Color(hex: "#E3F2FD"))
    }

    private var deleteAction: some View {
        Button {
            alertManager.show(
                title: localized("task.deleteTaskTitle"),
                message: localized("task.deleteTaskSubTitle"),
                buttons: [
                    AlertButton(
                        title: localized("task.deleteButton"),
                        action: confirmDelete,
                        buttonVariant: .danger
                    ),
                    AlertButton(
                        title: localized("task.cancelButton"),
                        action: { alertManager.hide() },
                        buttonVariant: .normal
                    )
                ]
            )
        } label: {
            Image("trash")
        }
        .tint(Color(hex: "#FFEBEE"))
    }

    private var favoriteAction: some View {
        Button(action: toggleFavorite) {
            Image(task.favorite ? "filledStar" : "emptyStar")
                .tint(Color(hex: "#FFB300"))
        }
        .tint(Color(hex: "#FFF8E1"))
    }

    // MARK: - Handlers

    private func confirmDelete() {
        Task {
            do {
                try deleteTaskAPI(documentID: task.documentID ?? "")
                deleteTask(task.documentID ?? "")
            } catch {
                alertManager.show(message: error.userFacingMessage)
            }
        }
    }

    private func toggleFavorite() {
        Task {
            do {
                var updated = task
                updated.favorite.toggle()

                try updateTaskAPI(task: updated)
                task.favorite.toggle()

                if task.favorite {
                    saveFavoriteTaskInStorage(task)
                    if let documentID = task.documentID {
                        makeTaskUnfavorite(documentID)
                    }
                } else {
                    saveFavoriteTaskInStorage(nil)
                }
            } catch {
                alertManager.show(message: error.userFacingMessage)
            }
        }
    }

    private func playSwipeHintIfNeeded() {
        guard showSwipeHint else { return }

        withAnimation(Self.hintSpring) { hintOffset = -30 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(Self.hintSpring) { hintOffset = 0 }
        }
    }
}

extension View {
    func taskSwipeActions(
        task: Binding<ToDoTask>,
        showSwipeHint: Bool,
        deleteTask: @escaping (String) -> Void,
        makeTaskUnfavorite: @escaping (String) -> Void
    ) -> some View {
        modifier(
            TaskSwipeActionsModifier(
                task: task,
                showSwipeHint: showSwipeHint,
                deleteTask: deleteTask,
                makeTaskUnfavorite: makeTaskUnfavorite
            )
        )
    }
}
