//
//  CreateNewTask.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 09/11/1447 AH.
//

import SwiftUI

struct CreateNewTask: View {
    @State private var title = ""
    @State private var description = ""
    @State private var selectedDate = ""
    @State private var selectedDateObject = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    @State private var shouldAddToCalendar = false
    @State private var color: ColorsToDo = .red

    @EnvironmentObject private var appColors: AppColors
    @EnvironmentObject private var toastManager: ToastManager
    @EnvironmentObject private var alertManager: AlertManager
    @EnvironmentObject private var loadingManager: LoadingManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var taskStore: TaskStore

    private var isSubmitDisabled: Bool { title.isEmpty }

    var body: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .pad {
                Color.clear
                    .background {
                        Image(color.assetName)
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                    }
                    .overlay(alignment: .bottom) {
                        iPadFormCard
                    }
            } else {
                ZStack(alignment: .bottom) {
                    Image(color.assetName)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    formCard
                }
            }
        }
        .onAppear {
            color = appColors.nextColor()
        }
    }

    private var formFields: some View {
        VStack(spacing: 16) {
            TextInput(
                data: $title,
                placeholder: localized("task.title"),
                error: title.isEmpty ? localized("task.titleRequired") : ""
            )
            DateInput(
                selectedDate: $selectedDate,
                onDateSelected: { selectedDateObject = $0 },
                dateIconColor: color.hex,
                placeholder: localized("task.dateOptional")
            )
            TextInput(
                data: $description,
                placeholder: localized("task.description"),
                isTextArea: true
            )

            if !selectedDate.isEmpty {
                Toggle(isOn: $shouldAddToCalendar) {
                    Text(localized("task.addToCalendar"))
                }
            }

            ButtonComponent(action: submit) {
                Text(localized("common.submit"))
            }
            .formButtonStyle()
            .isButtonDisabled(isSubmitDisabled)
        }
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(.white)
            .shadow(radius: 6)
            .ignoresSafeArea()
    }

    private var formCard: some View {
        formFields
            .padding(12)
            .frame(width: UIScreen.main.bounds.width)
            .background(cardBackground)
    }

    private var iPadFormCard: some View {
        formFields
            .padding(12)
            .frame(maxWidth: .infinity)
            .background(cardBackground)
    }

    private func submit() {
        Task { @MainActor in
            loadingManager.isLoadingButton = true
            defer { loadingManager.isLoadingButton = false }

            do {
                let calendarId = await TaskCalendarSync.sync(
                    title: title,
                    description: description,
                    endDate: selectedDateObject,
                    existingEventId: "",
                    shouldSync: shouldAddToCalendar,
                    toastManager: toastManager,
                    alertManager: alertManager
                )

                let mainTask = MainTask(
                    calendarId: calendarId,
                    color: color.hex,
                    date: selectedDate,
                    description: description,
                    status: false,
                    title: title
                )
                let documentID = try await addTaskAPI(
                    task: ToDoTask(mainTask: mainTask, subTasks: [])
                )

                toastManager.show(localized("task.addedSuccesfully"))

                let createdTask = ToDoTask(
                    documentID: documentID,
                    mainTask: mainTask,
                    subTasks: []
                )
                taskStore.tasks.insert(createdTask, at: 0)
                navigationManager.path.removeAll()
                navigationManager.path.append(.taskDetails(createdTask))
            } catch {
                alertManager.show(message: error.userFacingMessage)
            }
        }
    }
}

#Preview {
    CreateNewTask()
}
