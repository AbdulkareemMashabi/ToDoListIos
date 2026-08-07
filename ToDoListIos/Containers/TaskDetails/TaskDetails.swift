//
//  TaskDetails.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 20/02/1448 AH.
//

import SwiftUI

struct TaskDetails: View {
    @State var task: ToDoTask
    @State private var isPresented: Bool
    @State private var isAddedToCalnedar: Bool
    @State private var selectedDateObject: Date
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var title: String
    @State private var description: String
    @State private var date: String
    @State private var subTasks: [SubTasks]
    @State private var isTaskChanged: Bool
    @State private var newSubTask: String
    
    init(task: ToDoTask) {
        self.task = task
        self.isPresented = false
        self.isAddedToCalnedar = !task.mainTask.calendarId.isEmpty
        self.selectedDateObject = Date()
        self.title = task.mainTask.title
        self.description = task.mainTask.description
        self.date = task.mainTask.date
        self.subTasks = task.subTasks
        self.isTaskChanged = false
        self.newSubTask = ""
    }
    
    var body: some View {
        VStack(alignment: .leading){
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
                        isPresented = true
                    } label: {
                        Image("edit")
                    }
                }
                
            }
            if(!subTasks.isEmpty)
            {
                Divider().padding(.vertical, 8)
                Text(localized("taskDetails.subTasks")).font(.title3).bold().foregroundStyle(.gray)
                List(Array(subTasks.enumerated()), id: \.element.id) { index, item in
                    HStack {
                        if item.status {
                            Image("check").padding(.trailing, 8)
                        }

                        Text(item.title).bold()

                        Spacer()

                        Button {
                             subTasks.remove(at: index)
                            isTaskChanged = true
                        } label: {
                            Image("delete")
                        }
                    }                   .listRowSeparator(.hidden)
                        .listRowInsets(    EdgeInsets(
                            top: 16,
                            leading: 5,
                            bottom: 0,
                            trailing: 5
                        ))
                        .listRowBackground(Color.clear)
                }.scrollIndicators(.hidden).listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(.white)
            }
            TextInput(data: $newSubTask, placeholder: localized("taskDetails.subTasksPlaceHolder"), onBlur: {
                subTasks.append(SubTasks(id: UUID(), title: newSubTask, status: false))
                newSubTask = ""
                isTaskChanged = true
            }).padding(.top, 8)
            TextInput(data: $newSubTask, placeholder: localized("taskDetails.subTasksPlaceHolder"), onBlur: {
                subTasks.append(SubTasks(id: UUID(), title: newSubTask, status: false))
                newSubTask = ""
            }).padding(.top, 8)
        }.customToolbar(title: task.mainTask.title, rightButtons: isTaskChanged ? [
            AnyView(
            ButtonComponent {
                print("")
            } label: {
                Text(localized("taskDetails.done")).foregroundColor(.cyan)
            }
            )
        ] : []).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).padding(.horizontal).sheet(isPresented: $isPresented, onDismiss: {
            title = task.mainTask.title
            description = task.mainTask.description
            date = task.mainTask.date
            isAddedToCalnedar = !task.mainTask.calendarId.isEmpty
        }){
            VStack{
                TextInput(data: $title, placeholder: localized("task.title") ,error: title.isEmpty ? localized("task.titleRequired") : "")
                DateInput(selectedDate: $task.mainTask.date, onDateSelected: { date in
                    selectedDateObject = date
                }, placeholder: localized("task.dateOptional"))
                TextInput(data: $task.mainTask.description, placeholder: localized("task.description"), isTextArea: true)
                Toggle(isOn: $isAddedToCalnedar) {
                    Text(localized("task.addToCalendar"))
                }.padding(.vertical, 8).disabled(!task.mainTask.calendarId.isEmpty)
                ButtonComponent {
                    task.mainTask.title = title
                    task.mainTask.description = task.mainTask.description
                    task.mainTask.date = task.mainTask.date
                    isTaskChanged = true
                } label: {
                    Text(localized("common.submit"))
                }.formButtonStyle().disabled(title.isEmpty)
            }.frame(maxHeight: .infinity,alignment: .top).padding().presentationDetents([.height(400)])
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
            SubTasks(id: UUID(), title: "To Do", status: false)
        ]
    )

    TaskDetails(task: task)
}
