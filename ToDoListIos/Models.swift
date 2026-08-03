//
//  Models.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 09/06/1447 AH.
//

import Foundation
import FirebaseFirestore

struct User: Codable {
    let email: String?
    let password: String?
    let deviceId: String?
}

struct LoginBody: Codable {
    let token: String
    let userId: String
}

struct MainTask: Codable, Hashable {
    let calendarId: String
    let color: String
    var date: String
    var description: String
    var status: Bool
    var title: String

    enum CodingKeys: String, CodingKey {
        case calendarId
        case color
        case date
        case description
        case status
        case title
    }

    init(
        calendarId: String,
        color: String,
        date: String,
        description: String,
        status: Bool,
        title: String,
    ) {
        self.calendarId = calendarId
        self.color = color
        self.date = date
        self.description = description
        self.status = status
        self.title = title
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        calendarId = try container.decodeIfPresent(String.self, forKey: .calendarId) ?? ""
        color = try container.decode(String.self, forKey: .color)
        date = try container.decodeIfPresent(String.self, forKey: .date) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        status = try container.decode(Bool.self, forKey: .status)
        title = try container.decode(String.self, forKey: .title)
    }
}

struct SubTasks: Codable, Hashable {
    let title: String
    var status: Bool
}

struct ToDoTask: Codable, Hashable {
    @DocumentID var documentID: String?
    var favorite: Bool = false
    var mainTask: MainTask
    var subTasks: [SubTasks] = []
}
