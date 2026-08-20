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
    func loadFavoriteTask() -> ToDoTask? {
        let shared = UserDefaults(suiteName: "group.com.abdulkareem.ToDoList.widget")
        guard let data = shared?.data(forKey: "favoriteTask"),
              let task = try? JSONDecoder().decode(ToDoTask.self, from: data) else {
            return nil
        }
        return task
    }

    func placeholder(in context: Context) -> ToDoTask {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return ToDoTask(
            favorite: true,
            mainTask: MainTask(calendarId: "", color: "#FF3B30", date: formatter.string(from: Date()), description: "", status: false, title: "Finish Homework"),
            subTasks: [SubTask(title: "Math", status: true), SubTask(title: "Science", status: false)]
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ToDoTask) -> ()) {
        completion(loadFavoriteTask() ?? placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ToDoTask>) -> ()) {
        let entry = loadFavoriteTask() ?? ToDoTask(
            mainTask: MainTask(calendarId: "", color: "", date: "", description: "", status: false, title: ""),
            subTasks: []
        )
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct ToDoAppWidgetEntryView: View {
    var entry: ToDoTask
    @Environment(\.widgetFamily) var family

    var body: some View {
        if entry.mainTask.title.isEmpty {
            emptyStateView
        } else {
            taskView
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "star")
                .font(.system(size: 32))
                .foregroundColor(.gray)
            Text(widgetLocalizedString("widget.noFavoriteTask"))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var taskView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                if entry.mainTask.status {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.green)
                } else {
                    Circle()
                        .stroke(
                            Color(hex: getWidgetBorderColor(date: entry.mainTask.date, status: entry.mainTask.status)),
                            lineWidth: 2
                        )
                        .frame(width: 20, height: 20)
                }

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
                HStack(spacing: 8) {
                    if subTask.status {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.green)
                    } else {
                        Circle()
                            .stroke(
                                Color(hex: subTask.status ? "#34C759" : "#FF9500"),
                                lineWidth: 2
                            )
                            .frame(width: 20, height: 20)
                    }

                    Text(subTask.title)
                        .font(.system(size: 12))
                        .lineLimit(1)
                }
                .padding(.leading, 16)
            }
        }
    }

    private func widgetLocalizedString(_ key: String) -> String {
        let shared = UserDefaults(suiteName: "group.com.abdulkareem.ToDoList.widget")
        print(shared?.string(forKey: "appLanguage"),"mdre")
        let langCode = shared?.string(forKey: "appLanguage") ?? Locale.current.language.languageCode?.identifier ?? "en"

        if let bundlePath = Bundle.main.path(forResource: langCode, ofType: "lproj"),
           let bundle = Bundle(path: bundlePath) {
            return NSLocalizedString(key, bundle: bundle, comment: "")
        }
        if let bundlePath = Bundle.main.path(forResource: "en", ofType: "lproj"),
           let bundle = Bundle(path: bundlePath) {
            return NSLocalizedString(key, bundle: bundle, comment: "")
        }
        return key
    }

    private func getWidgetBorderColor(date: String, status: Bool) -> String {
        guard !date.isEmpty else {
            return status ? "#34C759" : "#FF9500"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"

        guard let endDate = formatter.date(from: date) else {
            return status ? "#34C759" : "#FF9500"
        }

        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        let days = components.day ?? 0

        if days >= 0 && !status {
            return "#FF9500"
        } else if days < 0 && !status {
            return "#FF3B30"
        } else {
            return "#34C759"
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

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
