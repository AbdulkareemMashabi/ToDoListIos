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
            ForEach(tasks, id:\.documentID) { task in
                HStack {
                    Circle()
                        .stroke(
                            Color(hex: getBorderColor(date: task.mainTask.date,
                                                      status: task.mainTask.status)),
                            lineWidth: 2
                        )
                        .frame(width: 20, height: 20)

                    VStack(alignment: .leading) {
                        Text(task.mainTask.title)

                        if let date = task.mainTask.date {
                            Text(date)
                        }

                        if (!task.subTasks.isEmpty)
                        {
                            Divider()
                        }
                           

                        ForEach(task.subTasks, id: \.title) { subTask in
                            HStack {
                                Circle()
                                    .stroke(
                                        Color(
                                            hex: subTask.status
                                                ? ColorsToDo.green.color
                                                : ColorsToDo.orange.color
                                        ),
                                        lineWidth: 2
                                    )
                                    .frame(width: 20, height: 20)

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
