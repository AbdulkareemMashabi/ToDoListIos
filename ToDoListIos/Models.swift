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

struct MainTask : Codable {
    let calendarId: String?
    let color: String
    let date: String?
    let description: String?
    var status: Bool
    let title: String
}

struct SubTasks: Codable {
    let title: String
    var status: Bool
}

struct ToDoTask: Codable {
    @DocumentID var documentID: String?
    var mainTask: MainTask
    var subTasks: [SubTasks]
}
