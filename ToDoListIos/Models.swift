//
//  Models.swift
//  ToDoListIos
//
//  Created by Abdulkareem Mashabi on 09/06/1447 AH.
//


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
    let status: Bool
    let title: String
}

struct SubTasks: Codable {
    let title: String
    let status: Bool
}

struct ToDoTask:Codable {
    let mainTask: MainTask
    let subTasks: [SubTasks]
}
