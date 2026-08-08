//
//  CreateNewTask.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 09/11/1447 AH.
//

import SwiftUI

struct CreateNewTask: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var isPresented: Bool = false
    @State private var selectedDate: String = ""
    @State private var selectedDateObject: Date = Calendar.current.date(
        byAdding: .day,
        value: 1,
        to: Date()
    )!
    @EnvironmentObject private var appColors: AppColors
    @EnvironmentObject private var toastManager: ToastManager
    @EnvironmentObject private var alertManager: AlertManager
    @EnvironmentObject var loadingManager: LoadingManager
    @EnvironmentObject private var navigationManager: NavigationManager
    private var isButtonDisabled: Bool {
        return title.isEmpty
    }
    @State private var color: ColorsToDo = ColorsToDo.red
    
    var body: some View {
        ZStack(alignment: .bottom){
            Image(color.image).resizable()
                .scaledToFill().ignoresSafeArea()
        
   
            VStack {
                TextInput(data: $title, placeholder: localized("task.title") ,error: title.isEmpty ? localized("task.titleRequired") : "")
                DateInput(selectedDate: $selectedDate, onDateSelected: { date in
                    selectedDateObject = date
                }, dateIconColor: color.color, placeholder: localized("task.dateOptional"))
                TextInput(data: $description, placeholder: localized("task.description"), isTextArea: true)
                
                if !selectedDate.isEmpty {
                        Toggle(isOn: $isPresented) {
                            Text(localized("task.addToCalendar"))
                        }.padding(.vertical, 8)
                }
                
                ButtonComponent {
                    Task {
                        do {
                            var eventIdTask: String = ""
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                            }
                            if isPresented {
                                CalendarManager.shared.requestAccess { granted in
                                    if granted {
                                        let (added, eventId) = CalendarManager.shared.addEvent(
                                            title: title,
                                            description: description,
                                            startDate: Date(),
                                            endDate: selectedDateObject
                                        )
                                        eventIdTask = eventId ?? ""
                                        if added {
                                            toastManager.show(localized("task.addedToCalendar"))
                                        } else {
                                            alertManager.show(message: localized("task.failedToAddToCalendar"))
                                        }
                                    } else {
                                        alertManager.show(message: localized("task.calendarAccessDenied"))
                                    }
                                }
                            }

                           let documentID = try await addTaskAPI(task: ToDoTask(mainTask: MainTask(calendarId: eventIdTask, color: color.color, date: selectedDate, description: description, status: false, title: title), subTasks: []))
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                                toastManager.show(localized("task.addedSuccesfully"))
                            }
                            let task = ToDoTask(documentID: documentID, mainTask: MainTask(calendarId: eventIdTask, color: color.color, date: selectedDate, description: description, status: false, title: title), subTasks: [])
                            navigationManager.path.append(.taskDetails(task))
                        }
                        catch {
                            await MainActor.run {
                                loadingManager.isLoadingButton.toggle()
                            }
                            let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                            alertManager.show(message: message)
                        }

                    }
                } label: {
                    Text(localized("common.submit"))
                }.formButtonStyle().isButtonDisabled(isButtonDisabled)
            }.padding(12).frame(width: UIScreen.main.bounds.width).background(    RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(radius: 6).ignoresSafeArea()).onAppear {
                    color = appColors.getImage()
                }
        }
        
    }
}

#Preview {
    CreateNewTask()
}
