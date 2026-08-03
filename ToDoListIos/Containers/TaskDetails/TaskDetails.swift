//
//  TaskDetails.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 20/02/1448 AH.
//

import SwiftUI

struct TaskDetails: View {
    @State var task: ToDoTask
    @State private var isPresented: Bool = false
    @State private var selectedDateObject: Date = Date()
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        VStack{
            HStack{
                VStack{
                    Text(task.mainTask.title)
                    if (!task.mainTask.description.isEmpty)
                    {
                        Text(task.mainTask.description)
                    }
                }
                Spacer()
                VStack{
                    if (!task.mainTask.date.isEmpty)
                    {
                        Text(task.mainTask.date)
                    }
                    Button {
                        
                    } label: {
                        Image("edit")
                    }
                }.background(.red)
                
            }
        }.sheet(isPresented: $isPresented){
            TextInput(data: $task.mainTask.title, placeholder: localized("task.title") ,error: task.mainTask.title.isEmpty ? localized("task.titleRequired") : "")
            DateInput(selectedDate: $task.mainTask.date, onDateSelected: { date in
                selectedDateObject = date
            }, placeholder: localized("task.dateOptional"))
            TextInput(data: $task.mainTask.description, placeholder: localized("task.description"), isTextArea: true)
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
            SubTasks(title: "To Do", status: false)
        ]
    )

    TaskDetails(task: task)
}
