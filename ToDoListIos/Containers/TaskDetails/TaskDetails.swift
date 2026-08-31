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
    @State private var selectedDateObject: Date

    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var loadingManager: LoadingManager
    @EnvironmentObject private var toastManager: ToastManager
    @EnvironmentObject private var alertManager: AlertManager
    @EnvironmentObject private var taskStore: TaskStore

    init(task: ToDoTask) {
        _task = State(initialValue: task)
        _draft = State(initialValue: Draft(task: task))
        _subTasks = State(initialValue: task.subTasks)
        _selectedDateObject = State(initialValue: Self.parseTaskDate(task.mainTask.date))
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
        .padding(.top)
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
        VStack(alignment: .leading, spacing: 4) {
            Divider().padding(.vertical, 8)
            Text(localized("taskDetails.subTasks"))
                .font(.title3)
                .bold()
                .foregroundStyle(.gray)

            ForEach(Array(subTasks.enumerated()), id: \.element.id) { index, item in
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
            }
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
        VStack(spacing: 16) {
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
                syncTaskStore()
                navigationManager.path.removeAll()
            } catch {
                alertManager.show(message: error.userFacingMessage)
            }
        }
    }

    /// Mirrors the just-saved local `task` back into the shared `TaskStore`
    /// so Dashboard reflects the edit without needing a re-fetch.
    private func syncTaskStore() {
        guard let index = taskStore.tasks.firstIndex(where: {
            $0.documentID == task.documentID
        }) else { return }
        taskStore.tasks[index] = task
    }

    /// Parses a task's stored date string into a `Date`. Tries the format
    /// `DateInput` actually writes (`.numeric` in the current locale) first,
    /// then a canonical `dd/MM/yyyy`, then a locale-aware short-date. Falls
    /// back to tomorrow so a missing or unparseable date never breaks the
    /// calendar sync.
    private static func parseTaskDate(_ dateString: String) -> Date {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        guard !dateString.isEmpty else { return tomorrow }

        // 1. Matches `pickerDate.formatted(date: .numeric, time: .omitted)`
        if let date = try? Date(dateString, strategy: Date.FormatStyle(date: .numeric, time: .omitted)) {
            return date
        }

        let formatter = DateFormatter()

        // 2. Canonical dd/MM/yyyy (older-stored dates or manual entries)
        formatter.dateFormat = "dd/MM/yyyy"
        if let date = formatter.date(from: dateString) { return date }

        // 3. Current-locale short style
        formatter.dateFormat = nil
        formatter.dateStyle = .short
        if let date = formatter.date(from: dateString) { return date }

        return tomorrow
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
