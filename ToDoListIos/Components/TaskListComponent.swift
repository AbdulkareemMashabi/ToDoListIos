//
//  TaskToDo.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 11/02/1448 AH.
//

import SwiftUI

struct TaskListComponent: View {
    @Binding var tasks: [ToDoTask]
    @EnvironmentObject var alertManager: AlertManager
    
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(tasks, id:\.documentID) { task in
                HStack {

                    StatusButton(
                        status: task.mainTask.status,
                        borderColor: Color(
                            hex: getBorderColor(
                                date: task.mainTask.date,
                                status: task.mainTask.status
                            )
                        )
                    ) {
                        do {
                            var updatedTask = task
                            updatedTask.mainTask.status = true

                            for index in updatedTask.subTasks.indices {
                                updatedTask.subTasks[index].status = true
                            }

                            try updateTaskAPI(task: updatedTask)
                        } catch {
                            let message =
                                (error as? LocalizedError)?.errorDescription ??
                                error.localizedDescription

                            alertManager.show(message: message)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text(task.mainTask.title)

                        if let date = task.mainTask.date, !date.isEmpty {
                            Text(date).foregroundColor(.gray)
                        }

                        if (!task.subTasks.isEmpty)
                        {
                            Divider()
                        }
                           

                        ForEach(Array(task.subTasks.enumerated()), id: \.offset) { index, subTask in
                            HStack {

                                StatusButton(
                                    status: subTask.status,
                                    borderColor: Color(
                                        hex: subTask.status
                                            ? ColorsToDo.green.color
                                            : ColorsToDo.orange.color
                                    )
                                ) {
                                    do {
                                        var updatedTask = task

                                        updatedTask.subTasks[index].status = true

                                        if updatedTask.subTasks.allSatisfy(\.status) {
                                            updatedTask.mainTask.status = true
                                        }

                                        try updateTaskAPI(task: updatedTask)
                                    } catch {
                                        let message =
                                            (error as? LocalizedError)?.errorDescription ??
                                            error.localizedDescription

                                        alertManager.show(message: message)
                                    }
                                }

                                Text(subTask.title)
                            }
                        }
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                .padding(.leading, 28)        // leave room for the colored bar
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 2)
                .overlay(alignment: .leading) {
                    LeftRoundedRectangle(radius: 16)
                        .fill(Color(hex: task.mainTask.color))
                        .frame(width: 20)
                }

            }
        }.frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    @Previewable @State var tasks: [ToDoTask] = [
        ToDoTask(
            mainTask: MainTask(
                calendarId: nil,
                color: "",
                date: "",
                description: "",
                status: false,
                title: "Task"
            ),
            subTasks: [
                SubTasks(title: "To Do", status: false)
            ]
        )
    ]
        TaskListComponent(tasks: $tasks)
}
