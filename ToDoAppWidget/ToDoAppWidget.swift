//
//  ToDoAppWidget.swift
//  ToDoAppWidget
//
//  Created by Abdulkareem Mashabi on 04/03/1448 AH.
//

import WidgetKit
import SwiftUI
import SharedModels

// MARK: - Constants

private enum WidgetConstants {
    static let favoriteTaskKey = "favoriteTask"
    static let languageKey = "appLanguage"
    static let fallbackLanguage = "en"
}

// MARK: - Timeline provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ToDoTask {
        let formatter = DateFormatter()
        formatter.dateFormat = TaskStatusColor.dateFormat
        return ToDoTask(
            favorite: true,
            mainTask: MainTask(
                calendarId: "",
                color: ColorsToDo.red.hex,
                date: formatter.string(from: Date()),
                description: "",
                status: false,
                title: "Finish Homework"
            ),
            subTasks: [
                SubTask(title: "Math", status: true),
                SubTask(title: "Science", status: false)
            ]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ToDoTask) -> Void) {
        completion(loadFavoriteTask() ?? placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ToDoTask>) -> Void) {
        let entry = loadFavoriteTask() ?? emptyEntry
        completion(Timeline(entries: [entry], policy: .atEnd))
    }

    private var emptyEntry: ToDoTask {
        ToDoTask(
            mainTask: MainTask(calendarId: "", color: "", date: "", description: "", status: false, title: ""),
            subTasks: []
        )
    }

    private func loadFavoriteTask() -> ToDoTask? {
        let shared = UserDefaults(suiteName: WidgetAction.suiteName)
        guard let data = shared?.data(forKey: WidgetConstants.favoriteTaskKey) else {
            return nil
        }
        return try? JSONDecoder().decode(ToDoTask.self, from: data)
    }
}

// MARK: - Entry view

struct ToDoAppWidgetEntryView: View {
    let entry: ToDoTask
    @Environment(\.widgetFamily) private var family

    var body: some View {
        if entry.mainTask.title.isEmpty {
            emptyStateView
        } else if family == .accessoryRectangular {
            accessoryRectangularView
        } else {
            taskView
        }
    }

    // MARK: - Layouts

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "star")
                .font(.system(size: 32))
                .foregroundColor(.gray)
            Text(widgetLocalized("widget.noFavoriteTask"))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var accessoryRectangularView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: entry.mainTask.status ? "checkmark.circle.fill" : "circle")
                    .font(.caption)
                    .foregroundColor(entry.mainTask.status ? .green : .orange)
                Text(entry.mainTask.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundColor(.white)
            }
            if !entry.subTasks.isEmpty {
                Text("\(completedSubTasksCount)/\(entry.subTasks.count)")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(accessoryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var taskView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                mainStatusCircle
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.mainTask.title)
                        .font(.system(size: 14, weight: .bold))
                        .lineLimit(2)
                    if !entry.mainTask.date.isEmpty {
                        Text(entry.mainTask.date)
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                }
            }

            if !entry.subTasks.isEmpty {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                    .padding(.vertical, 4)
            }

            ForEach(Array(entry.subTasks.enumerated()), id: \.element.id) { index, subTask in
                subTaskRow(index: index, subTask: subTask)
            }
        }
    }

    // MARK: - Components

    @ViewBuilder
    private var mainStatusCircle: some View {
        if let docID = entry.documentID,
           let url = WidgetAction.buildURL(docID: docID) {
            Link(destination: url) {
                statusCircle(isCompleted: entry.mainTask.status, dueDate: entry.mainTask.date)
            }
        } else {
            statusCircle(isCompleted: entry.mainTask.status, dueDate: entry.mainTask.date)
        }
    }

    @ViewBuilder
    private func subTaskRow(index: Int, subTask: SubTask) -> some View {
        HStack(spacing: 8) {
            if let docID = entry.documentID,
               let url = WidgetAction.buildURL(docID: docID, subTaskIndex: index) {
                Link(destination: url) {
                    subStatusCircle(isCompleted: subTask.status)
                }
            } else {
                subStatusCircle(isCompleted: subTask.status)
            }
            Text(subTask.title)
                .font(.system(size: 12))
                .lineLimit(1)
        }
        .padding(.leading, 16)
    }

    private func statusCircle(isCompleted: Bool, dueDate: String) -> some View {
        Group {
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.green)
            } else {
                Circle()
                    .stroke(
                        Color(TaskStatusColor.borderColor(dueDate: dueDate, isCompleted: isCompleted)),
                        lineWidth: 2
                    )
                    .frame(width: 20, height: 20)
            }
        }
    }

    private func subStatusCircle(isCompleted: Bool) -> some View {
        Group {
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.green)
            } else {
                Circle()
                    .stroke(Color(isCompleted ? .green : .orange), lineWidth: 2)
                    .frame(width: 20, height: 20)
            }
        }
    }

    private var accessoryBackground: LinearGradient {
        let tint: Color = entry.mainTask.status ? .green : .orange
        return LinearGradient(
            colors: [tint.opacity(0.15), tint.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Derived values

    private var completedSubTasksCount: Int {
        entry.subTasks.filter(\.status).count
    }

    private func widgetLocalized(_ key: String) -> String {
        let shared = UserDefaults(suiteName: WidgetAction.suiteName)
        let langCode = shared?.string(forKey: WidgetConstants.languageKey)
            ?? Locale.current.language.languageCode?.identifier
            ?? WidgetConstants.fallbackLanguage
        return SharedLocalization.string(for: key, languageCode: langCode)
    }
}

// MARK: - Widget definition

struct ToDoAppWidget: Widget {
    let kind: String = "ToDoAppWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ToDoAppWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Favorite Task")
        .description("Keep track of your favorite task")
        .supportedFamilies([
            .systemSmall, .systemMedium, .systemLarge,
            .accessoryRectangular
        ])
    }
}
