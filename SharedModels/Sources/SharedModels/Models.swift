import Foundation
import FirebaseFirestore
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
    public let date: Date = Date()
    @DocumentID public var documentID: String?
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
}
