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

    @EnvironmentObject private var alertManager: AlertManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var lottieManager: LottieManager

    @State private var player: AVAudioPlayer?

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                StatusButton(
                    status: task.mainTask.status,
                    borderColor: Color(TaskStatusColor.borderColor(
                        dueDate: task.mainTask.date,
                        isCompleted: task.mainTask.status
                    )),
                    action: completeMainTask
                )

                VStack(alignment: .leading) {
                    Text(task.mainTask.title).bold()
                    if !task.mainTask.date.isEmpty {
                        Text(task.mainTask.date).foregroundColor(.gray)
                    }
                }
            }

            if !task.subTasks.isEmpty {
                Divider().padding(.trailing, 8)
            }

            ForEach(Array(task.subTasks.enumerated()), id: \.offset) { index, subTask in
                HStack {
                    StatusButton(
                        status: subTask.status,
                        borderColor: Color(subTask.status ? .green : .orange)
                    ) {
                        completeSubTask(at: index)
                    }
                    Text(subTask.title)
                }
            }
            .padding(.leading, 16)
        }
        .padding(.vertical, 8)
        .onAppear {
            if task.favorite {
                saveFavoriteTaskInStorage(task)
            }
        }
    }

    // MARK: - Actions

    private func completeMainTask() {
        var updated = task
        updated.mainTask.status = true
        for i in updated.subTasks.indices {
            updated.subTasks[i].status = true
        }
        apply(updated: updated, triggerDoneAnimation: true)
    }

    private func completeSubTask(at index: Int) {
        var updated = task
        updated.subTasks[index].status = true
        let allDone = updated.subTasks.allSatisfy(\.status)
        if allDone { updated.mainTask.status = true }
        apply(updated: updated, triggerDoneAnimation: allDone)
    }

    private func apply(updated: ToDoTask, triggerDoneAnimation: Bool) {
        do {
            try updateTaskAPI(task: updated)
            task = updated
            try playSound()
            if triggerDoneAnimation {
                lottieManager.isDoneLottieEnabled.toggle()
            }
        } catch {
            alertManager.show(message: error.userFacingMessage)
        }
    }

    private func playSound() throws {
        guard let url = Bundle.main.url(forResource: "correct_sound", withExtension: "mp3") else {
            return
        }
        player = try AVAudioPlayer(contentsOf: url)
        player?.play()
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
            title: "Task"
        ),
        subTasks: [SubTask(id: UUID(), title: "To Do", status: false)]
    )
    TaskRow(task: $task)
}
