//
//  TaskRow.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 14/02/1448 AH.
//

import SwiftUI
import AVFoundation

struct TaskRow: View {
    @Binding var task: ToDoTask
    @EnvironmentObject var alertManager: AlertManager
    @State private var player: AVAudioPlayer?
    var deleteTask: (String) -> Void
    
    func playSound() throws {
        guard let url = Bundle.main.url(forResource: "correct_sound", withExtension: "mp3") else {
            fatalError("Audio file not found")
        }
        player = try AVAudioPlayer(contentsOf: url)
        player?.play()
    }
    
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
                    task = updatedTask
                    try playSound()
                } catch {
                    let message =
                        (error as? LocalizedError)?.errorDescription ??
                        error.localizedDescription

                    alertManager.show(message: message)
                }
            }
            
            VStack(alignment: .leading) {
                Text(task.mainTask.title).bold()

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
                                task = updatedTask
                                try playSound()
                            } catch {
                                let message =
                                    (error as? LocalizedError)?.errorDescription ??
                                    error.localizedDescription

                                alertManager.show(message: message)
                            }
                        }

                        Text(subTask.title)
                    }
                }.padding(.leading, 24)
            }
        }.swipeActions {
                ButtonComponent {
                    
                } label: {
                    Circle()
                        .fill(Color(hex: "#E3F2FD"))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image("info").foregroundColor(Color(hex: "#1976D2"))
                        )
                }
                
                ButtonComponent {
                    Task {
                        do {
                            try deleteTaskAPI(documentID: task.documentID ?? "")
                            deleteTask(task.documentID ?? "")
                        } catch {
                            let message =
                            (error as? LocalizedError)?.errorDescription ??
                            error.localizedDescription
                            
                            alertManager.show(message: message)
                        }
                    }
                } label: {
                    Circle()
                        .fill(Color(hex: "#FFEBEE"))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image("trash").foregroundColor(Color(hex: "#D32F2F"))
                        )
                }
                
                ButtonComponent {
                    
                } label: {
                    Circle()
                        .fill(Color(hex: "#FFF3E0"))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image("emptyStar").foregroundColor(Color(hex: "#F57C00"))
                        )
                }

        }
    }
}

#Preview {
    @State var task: ToDoTask = ToDoTask(
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

    TaskRow(task: $task, deleteTask: { _ in })
}
