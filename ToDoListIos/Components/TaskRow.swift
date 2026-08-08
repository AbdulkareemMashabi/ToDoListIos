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
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var player: AVAudioPlayer?
    var deleteTask: (String) -> Void
    var makeTaskUnfavorite: (String) -> Void
    
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
        VStack (alignment: .leading){
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

                    if !task.mainTask.date.isEmpty {
                        Text(task.mainTask.date).foregroundColor(.gray)
                    }
                       
                }
            }
            if (!task.subTasks.isEmpty)
            {
                Divider().padding(.trailing, 8)
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
            }.padding(.leading, 16)
        }.padding(.vertical, 8).swipeActions {
            Button {
                navigationManager.path.append(.taskDetails(task))
            } label: {
                Image("info")
            }.tint(Color(hex: "#E3F2FD"))
            
            Button {

                
                alertManager.show(title: localized("task.deleteTaskTitle"), message: localized("task.deleteTaskSubTitle"), buttons: [AlertButton(title: localized("task.deleteButton"), action: {
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
                    
                }, buttonVariant: .danger), AlertButton(title: localized("task.cancelButton"), action: {
                    alertManager.hide()
                    
                }, buttonVariant: .normal)])
            } label: {
                Image("trash")
            }.tint(Color(hex: "#FFEBEE"))
            
            Button {
                Task {
                    do {
                        var updatedTask = task
                        updatedTask.favorite.toggle()
                        
                        try updateTaskAPI(task: updatedTask)
                        task.favorite.toggle()
                        if(task.favorite){
                            makeTaskUnfavorite(task.documentID!)
                        }
                    } catch {
                        let message =
                        (error as? LocalizedError)?.errorDescription ??
                        error.localizedDescription
                        
                        alertManager.show(message: message)
                    }
                }
            } label: {
                Image(task.favorite ? "filledStar" : "emptyStar").tint(Color(hex: "#dbdb07"))
            }.tint(Color(hex: "#FFF3E0"))
            

        }
    }
}

#Preview {
    @Previewable @State var task: ToDoTask = ToDoTask(
        mainTask: MainTask(
            calendarId: "",
            color: "",
            date: "",
            description: "",
            status: false,
            title: "Task",
        ),
        subTasks: [
            SubTasks(id: UUID() ,title: "To Do", status: false)
        ]
    )

    TaskRow(task: $task, deleteTask: { _ in }, makeTaskUnfavorite: {_ in })
}
