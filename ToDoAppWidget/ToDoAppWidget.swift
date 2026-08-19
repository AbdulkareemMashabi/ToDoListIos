//
//  ToDoAppWidget.swift
//  ToDoAppWidget
//
//  Created by Abdulkareem Mashabi on 04/03/1448 AH.
//

import WidgetKit
import SwiftUI
import SharedModels

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ToDoTask {
        ToDoTask(
            favorite: true,
            mainTask: MainTask(calendarId: "", color: "", date: Date().ISO8601Format(), description: "", status: false, title: "Finish Homework"),
            subTasks: [SubTask(title: "Math", status: true), SubTask(title: "Science", status: false)]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ToDoTask) -> ()) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ToDoTask>) -> ()) {
        let entry = placeholder(in: context)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct ToDoAppWidgetEntryView: View {
    var entry: ToDoTask

    var body: some View {
        VStack(alignment: .leading) {
            Text(entry.mainTask.title).bold()
            if !entry.mainTask.date.isEmpty {
                Text(entry.mainTask.date).font(.caption).foregroundColor(.gray)
            }
        }
    }
}

struct ToDoAppWidget: Widget {
    let kind: String = "ToDoAppWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ToDoAppWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Favorite Task")
        .description("Keep track of your favorite task")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
