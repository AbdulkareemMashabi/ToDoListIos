//
//  TaskSwipeActionsModifier.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 25/02/1448 AH.
//

import SwiftUI

struct TaskSwipeActionsModifier: ViewModifier {
    @Binding var task: ToDoTask
    @Binding var showSwipeHint: Bool
    @EnvironmentObject private var alertManager: AlertManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var offset: CGFloat = 0
    
    let deleteTask: (String) -> Void
    let makeTaskUnfavorite: (String) -> Void
    
    func body(content: Content) -> some View {
        content.offset(x: offset).onAppear {
            if showSwipeHint {
                // go left
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
                    offset = -30
                }

                // then come back
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
                        offset = 0
                    }
                }
            }

        }
            .swipeActions {
                Button {
                    navigationManager.path.append(.taskDetails(task))
                } label: {
                    Image("info")
                }
                .tint(Color(hex: "#E3F2FD"))
                
                Button {
                    alertManager.show(
                        title: localized("task.deleteTaskTitle"),
                        message: localized("task.deleteTaskSubTitle"),
                        buttons: [
                            AlertButton(
                                title: localized("task.deleteButton"),
                                action: {
                                    Task {
                                        do {
                                            try deleteTaskAPI(
                                                documentID: task.documentID ?? ""
                                            )
                                            deleteTask(task.documentID ?? "")
                                        } catch {
                                            let message =
                                            (error as? LocalizedError)?.errorDescription ??
                                            error.localizedDescription
                                            
                                            alertManager.show(message: message)
                                        }
                                    }
                                },
                                buttonVariant: .danger
                            ),
                            AlertButton(
                                title: localized("task.cancelButton"),
                                action: {
                                    alertManager.hide()
                                },
                                buttonVariant: .normal
                            )
                        ]
                    )
                } label: {
                    Image("trash")
                }
                .tint(Color(hex: "#FFEBEE"))
                
                Button {
                    Task {
                        do {
                            var updatedTask = task
                            updatedTask.favorite.toggle()
                            
                            try updateTaskAPI(task: updatedTask)
                            task.favorite.toggle()                            
                            
                            if task.favorite {
                                saveFavoriteTaskInStorage(task)
                                makeTaskUnfavorite(task.documentID!)
                            }
                            else {
                                saveFavoriteTaskInStorage(nil)
                            }
                        } catch {
                            let message =
                            (error as? LocalizedError)?.errorDescription ??
                            error.localizedDescription
                            
                            alertManager.show(message: message)
                        }
                    }
                } label: {
                    Image(
                        task.favorite
                        ? "filledStar"
                        : "emptyStar"
                    )
                    .tint(Color(hex: "#FFB300"))
                }
                .tint(Color(hex: "#FFF8E1"))
            }
    }
}

extension View {
    func taskSwipeActions(
        task: Binding<ToDoTask>,
        showSwipeHint: Binding<Bool>,
        deleteTask: @escaping (String) -> Void,
        makeTaskUnfavorite: @escaping (String) -> Void
    ) -> some View {
        modifier(
            TaskSwipeActionsModifier(
                task: task,
                showSwipeHint: showSwipeHint,
                deleteTask: deleteTask,
                makeTaskUnfavorite: makeTaskUnfavorite,
            )
        )
    }
}
