import Foundation
import WidgetKit

public struct MainTask: Codable, Hashable {
    public var calendarId: String
    public let color: String
    public var date: String
    public var description: String
    public var status: Bool
    public var title: String

    enum CodingKeys: String, CodingKey {
        case calendarId
        case color
        case date
        case description
        case status
        case title
    }

    public init(
        calendarId: String,
        color: String,
        date: String,
        description: String,
        status: Bool,
        title: String
    ) {
        self.calendarId = calendarId
        self.color = color
        self.date = date
        self.description = description
        self.status = status
        self.title = title
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        calendarId = try container.decodeIfPresent(String.self, forKey: .calendarId) ?? ""
        color = try container.decode(String.self, forKey: .color)
        date = try container.decodeIfPresent(String.self, forKey: .date) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        status = try container.decode(Bool.self, forKey: .status)
        title = try container.decode(String.self, forKey: .title)
    }
}

public struct SubTask: Codable, Hashable, Identifiable {
    public let id: UUID
    public let title: String
    public var status: Bool

    public init(id: UUID = UUID(), title: String, status: Bool) {
        self.id = id
        self.title = title
        self.status = status
    }
}

public struct ToDoTask: Codable, Hashable, TimelineEntry {
    public var date: Date = Date()
    public var documentID: String?
    public var favorite: Bool = false
    public var mainTask: MainTask
    public var subTasks: [SubTask] = []

    public init(
        documentID: String? = nil,
        favorite: Bool = false,
        mainTask: MainTask,
        subTasks: [SubTask] = []
    ) {
        self.documentID = documentID
        self.favorite = favorite
        self.mainTask = mainTask
        self.subTasks = subTasks
    }

    enum CodingKeys: String, CodingKey {
        case documentID
        case favorite
        case mainTask
        case subTasks
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        documentID = try container.decodeIfPresent(String.self, forKey: .documentID)
        favorite = try container.decodeIfPresent(Bool.self, forKey: .favorite) ?? false
        mainTask = try container.decode(MainTask.self, forKey: .mainTask)
        subTasks = try container.decodeIfPresent([SubTask].self, forKey: .subTasks) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(documentID, forKey: .documentID)
        try container.encode(favorite, forKey: .favorite)
        try container.encode(mainTask, forKey: .mainTask)
        try container.encode(subTasks, forKey: .subTasks)
    }
}
