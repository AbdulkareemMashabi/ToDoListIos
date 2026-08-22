//
//  TaskListComponent.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 11/02/1448 AH.
//

import SwiftUI

struct TaskListComponent: View {
    @Binding var tasks: [ToDoTask]
    @State private var showSwipeHint: Bool

    @EnvironmentObject private var appToken: AppToken
    @EnvironmentObject private var loadingManager: LoadingManager
    @EnvironmentObject private var alertManager: AlertManager

    init(tasks: Binding<[ToDoTask]>) {
        _tasks = tasks
        showSwipeHint = tasks.count == 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            List($tasks, id: \.documentID) { $task in
                TaskRow(task: $task)
                    .frame(maxWidth: .infinity, minHeight: 60, alignment: .leading)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 16, leading: 5, bottom: 0, trailing: 5))
                    .listRowBackground(Color.clear)
                    .padding(.leading, 34) // leave room for the colored bar
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    .overlay(alignment: .leading) { colorAccent(for: task) }
                    .onChange(of: tasks.count) { showSwipeHint = tasks.count == 1 }
                    .taskSwipeActions(
                        task: $task,
                        showSwipeHint: $showSwipeHint,
                        deleteTask: deleteTask,
                        makeTaskUnfavorite: makeTaskUnfavorite
                    )
            }
            .scrollIndicators(.hidden)
            .onChange(of: tasks) { moveFavoriteToTop() }
            .refreshable { await refreshTasks() }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(.white)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear { moveFavoriteToTop() }
    }

    // MARK: - Subviews

    private func colorAccent(for task: ToDoTask) -> some View {
        ZStack {
            LeftRoundedRectangle(radius: 16)
                .fill(Color(hex: task.mainTask.color))
                .frame(width: 28)

            if task.favorite {
                Image("filledStar").foregroundColor(Color(hex: "#dbdb07"))
            }
        }
    }

    // MARK: - Actions

    private func deleteTask(documentID: String) {
        guard let index = tasks.firstIndex(where: { $0.documentID == documentID }) else { return }
        tasks.remove(at: index)
    }

    private func moveFavoriteToTop() {
        guard
            let index = tasks.firstIndex(where: { $0.favorite }),
            index != 0
        else { return }

        withAnimation(.easeInOut(duration: 0.15)) {
            let task = tasks.remove(at: index)
            tasks.insert(task, at: 0)
        }
    }

    /// If another task was favorite before, un-favorite it so only one favorite
    /// exists at a time, then bring the new favorite to the top.
    private func makeTaskUnfavorite(documentID: String) {
        guard let index = tasks.firstIndex(where: {
            $0.favorite && ($0.documentID ?? "") != documentID
        }) else {
            moveFavoriteToTop()
            return
        }

        do {
            var updated = tasks[index]
            updated.favorite = false
            try updateTaskAPI(task: updated)
            tasks[index].favorite = false
            moveFavoriteToTop()
        } catch {
            alertManager.show(message: error.userFacingMessage)
        }
    }

    private func refreshTasks() async {
        let newTasks = await loadTasksShared(
            appToken: appToken,
            loadingManager: loadingManager,
            alertManager: alertManager
        )
        if !newTasks.isEmpty {
            tasks = newTasks
        }
    }
}

#Preview {
    @Previewable @State var tasks: [ToDoTask] = [
        ToDoTask(
            mainTask: MainTask(
                calendarId: "",
                color: "",
                date: "",
                description: "",
                status: false,
                title: "Task"
            ),
            subTasks: [SubTask(id: UUID(), title: "To Do", status: false)]
        )
    ]
    TaskListComponent(tasks: $tasks)
}
