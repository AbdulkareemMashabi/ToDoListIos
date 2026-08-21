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
    @EnvironmentObject var loadingManager: LoadingManager
    @EnvironmentObject private var toastManager: ToastManager
    @EnvironmentObject private var alertManager: AlertManager
    @State private var title: String
    @State private var description: String
    @State private var date: String
    @State private var subTasks: [SubTask]
    @State private var isTaskChanged: Bool
    @State private var newSubTask: String
    @State private var didPressDone = false

    init(task: ToDoTask) {
        self.task = task
        self.isPresented = false
        self.isAddedToCalnedar = !task.mainTask.calendarId.isEmpty
        self.selectedDateObject = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: Date()
        )!
        self.title = task.mainTask.title
        self.description = task.mainTask.description
        self.date = task.mainTask.date
        self.subTasks = task.subTasks
        self.isTaskChanged = false
        self.newSubTask = ""
    }

    private func performCalendarIfNeeded(title: String, description: String, selectedDateObject: Date, existingEventId: String, isAddedToCalendar: Bool) async -> String {
        await withCheckedContinuation { continuation in
            // Default to existingEventId; may be replaced
            var resultEventId = existingEventId
            guard isAddedToCalendar else {
                continuation.resume(returning: resultEventId)
                return
            }
            CalendarManager.shared.requestAccess { granted in
                if granted {
                    if existingEventId.isEmpty {
                        let (added, eventId) = CalendarManager.shared.addEvent(
                            title: title,
                            description: description,
                            startDate: Date(),
                            endDate: selectedDateObject
                        )
                        if added {
                            toastManager.show(localized("task.addedToCalendar"))
                        } else {
                            alertManager.show(message: localized("task.failedToAddToCalendar"))
                        }
                        resultEventId = eventId ?? ""
                        continuation.resume(returning: resultEventId)
                    } else {
                        let updated = CalendarManager.shared.updateEvent(
                            eventId: existingEventId,
                            title: title,
                            description: description,
                            startDate: Date(),
                            endDate: selectedDateObject
                        )
                        if updated {
                            toastManager.show(localized("task.updatedInCalendar"))
                        } else {
                            alertManager.show(message: localized("task.failedToUpdateCalendar"))
                        }
                        continuation.resume(returning: resultEventId)
                    }
                } else {
                    alertManager.show(message: localized("task.calendarAccessDenied"))
                    continuation.resume(returning: resultEventId)
                }
            }
        }
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
                                .frame(width: 44, height: 44)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }                   .listRowSeparator(.hidden)
                        .listRowInsets(    EdgeInsets(
                            top: 4,
                            leading: 5,
                            bottom: 0,
                            trailing: 5
                        ))
                        .listRowBackground(Color.clear)
                }.frame(height: CGFloat(subTasks.count * 60)).scrollIndicators(.hidden).listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(.white)
            }
            TextInput(data: $newSubTask, placeholder: localized("taskDetails.subTasksPlaceHolder"), onBlur: {
                if(!newSubTask.isEmpty)
                {
                    subTasks.append(SubTask(id: UUID(), title: newSubTask, status: false))
                    newSubTask = ""
                    isTaskChanged = true
                }
            })
        }.customToolbar(title: task.mainTask.title, rightButtons: isTaskChanged ? [
            AnyView(
            ButtonComponent {
                Task {
                    do {
                        await MainActor.run {
                            loadingManager.isLoadingButton.toggle()
                        }
                        let eventIdTask: String = await performCalendarIfNeeded(
                            title: title,
                            description: description,
                            selectedDateObject: selectedDateObject,
                            existingEventId: task.mainTask.calendarId,
                            isAddedToCalendar: isAddedToCalnedar
                        )
                        
                        task.mainTask.calendarId = eventIdTask
                        task.mainTask.title = title
                        task.mainTask.description = description
                        task.mainTask.date = date
                        task.subTasks = subTasks
                        
                        try updateTaskAPI(task: task)
                        navigationManager.path.removeAll()
                        
                        await MainActor.run {
                            loadingManager.isLoadingButton.toggle()
                        }
                    } catch {
                        await MainActor.run {
                            loadingManager.isLoadingButton.toggle()
                        }
                        let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                        alertManager.show(message: message)
                    }
                }
            } label: {
                Text(localized("taskDetails.done")).foregroundColor(.cyan)
            }
            )
        ] : []).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).padding(.horizontal).sheet(isPresented: $isPresented, onDismiss: {
            if didPressDone {
                didPressDone = false
            } else {
                title = task.mainTask.title
                description = task.mainTask.description
                date = task.mainTask.date
                isAddedToCalnedar = !task.mainTask.calendarId.isEmpty
            }
        }){
            VStack{
                TextInput(data: $title, placeholder: localized("task.title") ,error: title.isEmpty ? localized("task.titleRequired") : "")
                DateInput(selectedDate: $date, onDateSelected: { date in
                    selectedDateObject = date
                }, placeholder: localized("task.dateOptional"))
                TextInput(data: $description, placeholder: localized("task.description"), isTextArea: true)
                Toggle(isOn: $isAddedToCalnedar) {
                    Text(localized("task.addToCalendar"))
                }.padding(.vertical, 8).disabled(!task.mainTask.calendarId.isEmpty)
                ButtonComponent {
                    didPressDone = true
                    task.mainTask.title = title
                    task.mainTask.description = description
                    task.mainTask.date = date
                    isAddedToCalnedar = isAddedToCalnedar
                    isTaskChanged = true
                    isPresented = false
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
            SubTask(id: UUID(), title: "To Do", status: false)
        ]
    )

    TaskDetails(task: task)
}

