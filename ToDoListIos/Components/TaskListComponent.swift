//
//  TaskToDo.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 11/02/1448 AH.
//

import SwiftUI

struct TaskListComponent: View {
    @Binding var tasks: [ToDoTask]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            List(tasks, id:\.documentID) { task in
                TaskRow(task: task).frame(maxWidth: .infinity, minHeight: 60 ,alignment: .leading)
                    .listRowSeparator(.hidden)
                    .listRowInsets(    EdgeInsets(
                        top: 16,
                        leading: 5,
                        bottom: 0,
                        trailing: 5
                    ))
                    .listRowBackground(Color.clear)
                .padding(.leading, 28)        // leave room for the colored bar
                .background(Color.white)
                .cornerRadius(16)
                .shadow(radius: 2)
                .overlay(alignment: .leading) {
                    LeftRoundedRectangle(radius: 16)
                        .fill(Color(hex: task.mainTask.color))
                        .frame(width: 20)
                }

            }.listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(.white)
        }.frame(maxHeight: .infinity ,alignment: .top)
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
