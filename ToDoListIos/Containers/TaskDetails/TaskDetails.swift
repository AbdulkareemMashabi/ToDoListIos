//
//  TaskDetails.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 20/02/1448 AH.
//

import SwiftUI

struct TaskDetails: View {
    @State var task: ToDoTask
    @State private var draft: Draft
    @State private var subTasks: [SubTask]
    @State private var newSubTask = ""
    @State private var isTaskChanged = false
    @State private var isEditSheetPresented = false
    @State private var didConfirmEdit = false
    @State private var selectedDateObject = Calendar.current.date(byAdding: .day, value: 1, to: Date())!

    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var loadingManager: LoadingManager
    @EnvironmentObject private var toastManager: ToastManager
    @EnvironmentObject private var alertManager: AlertManager

    init(task: ToDoTask) {
        _task = State(initialValue: task)
        _draft = State(initialValue: Draft(task: task))
        _subTasks = State(initialValue: task.subTasks)
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading) {
            summarySection
            if !subTasks.isEmpty {
                subTasksSection
            }
            addSubTaskField
        }
        .customToolbar(
            title: task.mainTask.title,
            rightButtons: isTaskChanged ? [AnyView(saveButton)] : []
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal)
        .sheet(isPresented: $isEditSheetPresented, onDismiss: handleSheetDismiss) {
            editSheet
        }
    }

    // MARK: - Sections

    private var summarySection: some View {
        HStack {
            VStack {
                Text(task.mainTask.title)
                if !task.mainTask.description.isEmpty {
                    Text(task.mainTask.description)
                }
            }
            Spacer()
            VStack {
                if !task.mainTask.date.isEmpty {
                    Text(task.mainTask.date)
                }
                Button {
                    isEditSheetPresented = true
                } label: {
                    Image("edit")
                }
            }
        }
    }

    private var subTasksSection: some View {
        VStack(alignment: .leading) {
            Divider().padding(.vertical, 8)
            Text(localized("taskDetails.subTasks"))
                .font(.title3)
                .bold()
                .foregroundStyle(.gray)

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
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 4, leading: 5, bottom: 0, trailing: 5))
                .listRowBackground(Color.clear)
            }
            .frame(height: CGFloat(subTasks.count * 60))
            .scrollIndicators(.hidden)
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(.white)
        }
    }

    private var addSubTaskField: some View {
        TextInput(
            data: $newSubTask,
            placeholder: localized("taskDetails.subTasksPlaceHolder"),
            onBlur: {
                guard !newSubTask.isEmpty else { return }
                subTasks.append(SubTask(id: UUID(), title: newSubTask, status: false))
                newSubTask = ""
                isTaskChanged = true
            }
        )
    }

    private var saveButton: some View {
        ButtonComponent(action: save) {
            Text(localized("taskDetails.done")).foregroundColor(.cyan)
        }
    }

    private var editSheet: some View {
        VStack {
            TextInput(
                data: $draft.title,
                placeholder: localized("task.title"),
                error: draft.title.isEmpty ? localized("task.titleRequired") : ""
            )
            DateInput(
                selectedDate: $draft.date,
                onDateSelected: { selectedDateObject = $0 },
                placeholder: localized("task.dateOptional")
            )
            TextInput(
                data: $draft.description,
                placeholder: localized("task.description"),
                isTextArea: true
            )
            if !draft.date.isEmpty {
                Toggle(isOn: $draft.isInCalendar) {
                    Text(localized("task.addToCalendar"))
                }
                .padding(.vertical, 8)
                .disabled(!task.mainTask.calendarId.isEmpty)
            }

            ButtonComponent(action: applyDraft) {
                Text(localized("common.submit"))
            }
            .formButtonStyle()
            .disabled(draft.title.isEmpty)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
        .presentationDetents([.height(draft.date.isEmpty ? 340 : 400)])
    }

    // MARK: - Actions

    private func applyDraft() {
        didConfirmEdit = true
        task.mainTask.title = draft.title
        task.mainTask.description = draft.description
        task.mainTask.date = draft.date
        isTaskChanged = true
        isEditSheetPresented = false
    }

    private func handleSheetDismiss() {
        if didConfirmEdit {
            didConfirmEdit = false
        } else {
            draft = Draft(task: task)
        }
    }

    private func save() {
        Task { @MainActor in
            loadingManager.isLoading = true
            defer { loadingManager.isLoading = false }

            do {
                let calendarId = await TaskCalendarSync.sync(
                    title: draft.title,
                    description: draft.description,
                    endDate: selectedDateObject,
                    existingEventId: task.mainTask.calendarId,
                    shouldSync: draft.isInCalendar,
                    toastManager: toastManager,
                    alertManager: alertManager
                )

                task.mainTask.calendarId = calendarId
                task.mainTask.title = draft.title
                task.mainTask.description = draft.description
                task.mainTask.date = draft.date
                task.subTasks = subTasks

                try updateTaskAPI(task: task)
                navigationManager.path.removeAll()
            } catch {
                alertManager.show(message: error.userFacingMessage)
            }
        }
    }
}

// MARK: - Draft state

private struct Draft {
    var title: String
    var description: String
    var date: String
    var isInCalendar: Bool

    init(task: ToDoTask) {
        title = task.mainTask.title
        description = task.mainTask.description
        date = task.mainTask.date
        isInCalendar = !task.mainTask.calendarId.isEmpty
    }
}

#Preview {
    TaskDetails(
        task: ToDoTask(
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
    )
}
